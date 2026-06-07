# oauth_import_httr(): convert an httr .httr-oauth cache into a client + token.
# Uses a synthetic httr-shaped object (no real secrets, no httr dependency).

library(tinyoauth)

fake <- structure(list(
  app = list(key = "APPID", secret = "APPSECRET",
             redirect_uri = "http://127.0.0.1:1410/"),
  endpoint = list(access = "https://p/token", authorize = "https://p/authorize"),
  credentials = list(access_token = "AT", token_type = "Bearer",
                     refresh_token = "RT", expires_in = 3600, scope = "a b")
), class = c("Token2.0", "Token", "R6"))

# single cached token
f <- tempfile(fileext = ".httr-oauth")
saveRDS(fake, f)
imp <- oauth_import_httr(f)
expect_inherits(imp$client, "tinyoauth_client")
expect_equal(imp$client$id, "APPID")
expect_equal(imp$client$token_url, "https://p/token")
expect_equal(imp$client$auth_url, "https://p/authorize")
expect_inherits(imp$token, "tinyoauth_token")
expect_equal(imp$token$access_token, "AT")
expect_equal(imp$token$refresh_token, "RT")
expect_equal(imp$token$scope, "a b")
expect_true(oauth_expired(imp$token))      # forced stale -> refresh on first use
unlink(f)

# list-of-tokens cache (httr keys by a hash)
f2 <- tempfile(fileext = ".httr-oauth")
saveRDS(stats::setNames(list(fake), "deadbeef"), f2)
expect_equal(oauth_import_httr(f2)$client$id, "APPID")
expect_error(oauth_import_httr(f2, which = 2), "which")
unlink(f2)

# nothing usable / missing file
expect_error(oauth_import_httr(tempfile()), "no httr cache")
bad <- tempfile(fileext = ".httr-oauth"); saveRDS(list(1, 2), bad)
expect_error(oauth_import_httr(bad), "no httr Token2.0")
unlink(bad)
