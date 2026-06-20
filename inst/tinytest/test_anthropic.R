# Tests for the Anthropic Claude (Claude Code) login route. These cover the
# offline pieces (client config, PKCE, authorize URL, code parsing); the live
# browser flow is not exercised here.

# --- client config ---
cl <- anthropic_claude_client()
expect_inherits(cl, "tinyoauth_client")
expect_equal(cl$id, "9d1c250a-e61b-44d9-88ed-5944d1962f5e")
expect_equal(cl$token_url, "https://console.anthropic.com/v1/oauth/token")
expect_equal(cl$auth_url, "https://claude.ai/oauth/authorize")
expect_true(grepl("user:inference", cl$scope, fixed = TRUE))

# --- base64url: no padding, url-safe alphabet ---
b64 <- tinyoauth:::.b64url(charToRaw("any carnal pleasure."))
expect_false(grepl("=", b64, fixed = TRUE))
expect_false(grepl("[+/]", b64))

# --- PKCE: challenge is base64url(sha256(verifier)), S256-correct ---
pk <- tinyoauth:::.anthropic_pkce()
expect_true(nchar(pk$verifier) >= 43L && nchar(pk$verifier) <= 128L)
recomputed <- tinyoauth:::.b64url(
    digest::digest(charToRaw(pk$verifier), algo = "sha256",
                   serialize = FALSE, raw = TRUE))
expect_equal(pk$challenge, recomputed)
# Known-answer SHA-256 vector (RFC 7636 appendix B verifier).
v <- "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
expect_equal(
    tinyoauth:::.b64url(digest::digest(charToRaw(v), algo = "sha256",
                                       serialize = FALSE, raw = TRUE)),
    "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")

# --- authorize URL carries every required OAuth + PKCE param ---
u <- tinyoauth:::.anthropic_authorize_url(cl, pk, "STATE123")
expect_true(startsWith(u, "https://claude.ai/oauth/authorize?"))
expect_true(grepl("code_challenge_method=S256", u, fixed = TRUE))
expect_true(grepl(paste0("code_challenge=", pk$challenge), u, fixed = TRUE))
expect_true(grepl("response_type=code", u, fixed = TRUE))
expect_true(grepl("state=STATE123", u, fixed = TRUE))
expect_true(grepl("code=true", u, fixed = TRUE))

# --- code parsing: CODE#STATE, full callback URL, bare code, empty ---
p1 <- tinyoauth:::.anthropic_parse_code("AUTHCODE#STATE123")
expect_equal(p1$code, "AUTHCODE")
expect_equal(p1$state, "STATE123")

p2 <- tinyoauth:::.anthropic_parse_code(
    "https://console.anthropic.com/oauth/code/callback?code=ABC&state=XYZ")
expect_equal(p2$code, "ABC")
expect_equal(p2$state, "XYZ")

p3 <- tinyoauth:::.anthropic_parse_code("  BARECODE  ")
expect_equal(p3$code, "BARECODE")

expect_equal(length(tinyoauth:::.anthropic_parse_code("")), 0L)

# --- non-interactive: no token, no prompt -> NULL ---
expect_null(oauth_token_anthropic(cache = tempfile(), login = FALSE))
