# Tests for the OpenAI Codex device-login route

# --- helper: build a fake (unsigned) JWT from a payload list ---
make_jwt <- function(payload) {
    enc <- function(s) {
        # base64_enc line-wraps long output; strip newlines and padding for url-safe
        b64 <- gsub("[\n=]", "", jsonlite::base64_enc(charToRaw(s)))
        chartr("+/", "-_", b64)
    }
    paste(enc('{"alg":"none"}'),
          enc(jsonlite::toJSON(payload, auto_unbox = TRUE)),
          "sig", sep = ".")
}

# --- oauth_jwt_payload ---
jwt <- make_jwt(list(sub = "abc", n = 42L))
expect_equal(tinyoauth::oauth_jwt_payload(jwt)$sub, "abc")
expect_equal(tinyoauth::oauth_jwt_payload(jwt)$n, 42L)
# garbage / non-JWT inputs return NULL, not an error
expect_null(tinyoauth::oauth_jwt_payload("not-a-jwt"))
expect_null(tinyoauth::oauth_jwt_payload(NULL))
expect_null(tinyoauth::oauth_jwt_payload(123))

# A tinyoauth_token uses its access_token
tok <- structure(list(access_token = jwt), class = "tinyoauth_token")
expect_equal(tinyoauth::oauth_jwt_payload(tok)$sub, "abc")

# --- openai_codex_account_id ---
acct_jwt <- make_jwt(list("https://api.openai.com/auth" =
                          list(chatgpt_account_id = "acct_xyz")))
expect_equal(tinyoauth::openai_codex_account_id(acct_jwt), "acct_xyz")
# token without the claim -> NULL
expect_null(tinyoauth::openai_codex_account_id(make_jwt(list(sub = "x"))))

# --- openai_codex_client shape ---
cl <- tinyoauth::openai_codex_client()
expect_true(inherits(cl, "tinyoauth_client"))
expect_equal(cl$id, "app_EMoamEEZ73f0CkXaXp7hrann")
expect_equal(cl$token_url, "https://auth.openai.com/oauth/token")
expect_true(grepl("deviceauth/usercode$", cl$device_usercode_url))
expect_true(grepl("deviceauth/token$", cl$device_token_url))
expect_true(grepl("codex/device$", cl$verification_uri))

# --- .codex_poll_classify ---
expect_equal(tinyoauth:::.codex_poll_classify(200L,
             list(authorization_code = "ac", code_verifier = "v")), "ok")
expect_equal(tinyoauth:::.codex_poll_classify(400L,
             list(error = "deviceauth_authorization_pending")), "pending")
expect_equal(tinyoauth:::.codex_poll_classify(429L,
             list(error = "slow_down")), "slow_down")
expect_equal(tinyoauth:::.codex_poll_classify(400L,
             list(error = "access_denied")), "error")

# --- .codex_finalize attaches account_id ---
fin <- tinyoauth:::.codex_finalize(
    structure(list(access_token = acct_jwt), class = "tinyoauth_token"))
expect_equal(fin$account_id, "acct_xyz")
expect_null(tinyoauth:::.codex_finalize(NULL))

# --- .codex_device_poll: pending -> slow_down -> ok, with injected post/sleep ---
calls <- 0L
fake_post <- function(url, body) {
    calls <<- calls + 1L
    if (calls == 1L) {
        list(status = 400L, body = list(error = "deviceauth_authorization_pending"),
             raw = "")
    } else if (calls == 2L) {
        list(status = 429L, body = list(error = "slow_down"), raw = "")
    } else {
        list(status = 200L,
             body = list(authorization_code = "the_code", code_verifier = "the_verifier"),
             raw = "")
    }
}
auth <- tinyoauth:::.codex_device_poll(
    cl, list(device_auth_id = "d", user_code = "U", interval = 1),
    timeout = 60, sleep = function(...) invisible(NULL), post = fake_post)
expect_equal(auth$authorization_code, "the_code")
expect_equal(auth$code_verifier, "the_verifier")
expect_equal(calls, 3L)

# --- .codex_device_poll: hard error stops ---
expect_error(
    tinyoauth:::.codex_device_poll(
        cl, list(device_auth_id = "d", user_code = "U"),
        timeout = 60, sleep = function(...) invisible(NULL),
        post = function(url, body) list(status = 400L,
                body = list(error = "access_denied"), raw = "")),
    "device authorization failed")

# --- .codex_device_start: error on missing user_code ---
expect_error(
    tinyoauth:::.codex_device_start(cl,
        post = function(url, body) list(status = 500L, body = list(), raw = "boom")),
    "could not start device authorization")

# --- oauth_token_openai_codex: a valid cached token is returned without network ---
tmpcache <- tempfile(fileext = ".rds")
valid <- structure(list(access_token = "cached-at", refresh_token = "rt",
                        expires_at = Sys.time() + 3600, account_id = "acct_cached"),
                   class = "tinyoauth_token")
saveRDS(valid, tmpcache)
got <- tinyoauth::oauth_token_openai_codex(cache = tmpcache, open_url = FALSE)
expect_equal(got$access_token, "cached-at")
expect_equal(got$account_id, "acct_cached")
unlink(tmpcache)

# --- login = FALSE returns NULL (no prompt) when no usable token is cached ---
emptycache <- tempfile(fileext = ".rds")
expect_null(tinyoauth::oauth_token_openai_codex(cache = emptycache, login = FALSE))
expect_false(file.exists(emptycache))
