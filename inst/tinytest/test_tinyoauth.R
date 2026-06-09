# Pure-function tests (no network). The token grants need a live provider, so
# they're exercised via the listener test below (at_home only).

library(tinyoauth)

# --- form encoding ----------------------------------------------------------
expect_equal(tinyoauth:::.form_encode(list(a = 1, b = "x y")), "a=1&b=x%20y")
expect_equal(tinyoauth:::.form_encode(list(a = 1, b = NULL)), "a=1")  # NULLs dropped
expect_equal(tinyoauth:::.drop_null(list(a = 1, b = NULL, c = 2)),
             list(a = 1, c = 2))

# --- basic auth header ------------------------------------------------------
# base64("id:secret") = "aWQ6c2VjcmV0"
expect_equal(tinyoauth:::.basic_auth("id", "secret"), "Basic aWQ6c2VjcmV0")

# --- client construction + validation --------------------------------------
cl <- oauth_client("cid", secret = "sec",
                   token_url = "https://p/token", auth_url = "https://p/authorize")
expect_inherits(cl, "tinyoauth_client")
expect_error(oauth_client(id = "", token_url = "https://p/token"), "id")
expect_error(oauth_client(id = "x"), "token_url")

# --- authorize URL building -------------------------------------------------
u <- oauth_authorize_url(cl, scope = "a b", state = "S1")
expect_true(grepl("^https://p/authorize\\?", u))
expect_true(grepl("client_id=cid", u))
expect_true(grepl("response_type=code", u))
expect_true(grepl("scope=a%20b", u))
expect_true(grepl("state=S1", u))
expect_true(grepl("redirect_uri=http%3A%2F%2F127.0.0.1%3A1410%2F", u))
expect_error(oauth_authorize_url(oauth_client("x", token_url = "https://p/t")),
             "auth_url")

# --- redirect query parsing -------------------------------------------------
q <- tinyoauth:::.parse_request_query("GET /?code=ABC123&state=S1 HTTP/1.1")
expect_equal(q$code, "ABC123")
expect_equal(q$state, "S1")
expect_equal(length(tinyoauth:::.parse_request_query("GET / HTTP/1.1")), 0L)

# --- manual paste parsing (.parse_redirect_input) ---------------------------
# Full redirect URL as copied from the browser address bar
u1 <- tinyoauth:::.parse_redirect_input(
    "http://127.0.0.1:1410/?code=4/0Aabc-XYZ&state=S2&scope=foo")
expect_equal(u1$code, "4/0Aabc-XYZ")
expect_equal(u1$state, "S2")
# URL-encoded code (Google encodes the slash) is decoded
u2 <- tinyoauth:::.parse_redirect_input(
    "http://127.0.0.1:1410/?code=4%2F0Aabc&state=S3")
expect_equal(u2$code, "4/0Aabc")
# A bare query string (no scheme/host)
u3 <- tinyoauth:::.parse_redirect_input("code=ABC123&state=S4")
expect_equal(u3$code, "ABC123")
expect_equal(u3$state, "S4")
# Just the code on its own
expect_equal(tinyoauth:::.parse_redirect_input("4/0Aabc")$code, "4/0Aabc")
# An error redirect surfaces the error
expect_equal(tinyoauth:::.parse_redirect_input(
    "http://127.0.0.1:1410/?error=access_denied")$error, "access_denied")
# Whitespace and empty input
expect_equal(tinyoauth:::.parse_redirect_input("  4/0Aabc  ")$code, "4/0Aabc")
expect_equal(length(tinyoauth:::.parse_redirect_input("   ")), 0L)

# --- token helpers ----------------------------------------------------------
tok <- structure(list(access_token = "AT", refresh_token = "RT",
                      expires_at = Sys.time() + 3600),
                 class = "tinyoauth_token")
expect_equal(oauth_bearer(tok), "Bearer AT")
expect_equal(oauth_bearer("raw"), "Bearer raw")
expect_false(oauth_expired(tok))
expect_true(oauth_expired(structure(list(expires_at = Sys.time() - 1),
                                    class = "tinyoauth_token")))
expect_false(oauth_expired(structure(list(expires_at = NULL),
                                     class = "tinyoauth_token")))

# --- .as_token shape --------------------------------------------------------
t2 <- tinyoauth:::.as_token(list(access_token = "x", expires_in = 10))
expect_inherits(t2, "tinyoauth_token")
expect_equal(t2$token_type, "Bearer")
expect_true(!is.null(t2$expires_at))

# --- serverSocket listener round-trip (binds a port; local only) -----------
if (at_home()) {
  port <- 1411L
  system2("sh", c("-c", sprintf(
    "sleep 0.5; curl -s -o /dev/null 'http://127.0.0.1:%d/?code=LIVE&state=S9'",
    port)), wait = FALSE)
  q2 <- tinyoauth:::.listen_for_redirect(port = port, timeout = 10)
  expect_equal(q2$code, "LIVE")
  expect_equal(q2$state, "S9")
}
