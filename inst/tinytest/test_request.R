# oauth_request() + helpers.

library(tinyoauth)

# --- query/form encoding ----------------------------------------------------
expect_equal(tinyoauth:::.form_encode(list(a = 1, b = "x y", c = NULL)),
             "a=1&b=x%20y")
expect_equal(tinyoauth:::.form_encode(list()), "")
expect_equal(tinyoauth:::.form_encode(NULL), "")

# --- oauth_bearer accepts a legacy httr Token2.0 ----------------------------
ht <- structure(list(credentials = list(access_token = "HTOK")),
                class = c("Token2.0", "Token", "R6"))
expect_equal(oauth_bearer(ht), "Bearer HTOK")
expect_equal(oauth_bearer(structure(list(access_token = "TT"),
                                    class = "tinyoauth_token")), "Bearer TT")
expect_equal(oauth_bearer("raw"), "Bearer raw")

# --- live round-trip against a one-shot serverSocket HTTP responder --------
# (binds a port + needs littler; local only)
if (at_home()) {
  srv_file <- tempfile(fileext = ".R")
  writeLines(c(
    'srv <- serverSocket(1412L)',
    'con <- socketAccept(srv, blocking = TRUE, open = "r+", timeout = 10)',
    'invisible(readLines(con, n = 1, warn = FALSE))',
    'writeLines(paste0("HTTP/1.1 200 OK\\r\\n",',
    '  "Content-Type: application/json\\r\\nConnection: close\\r\\n\\r\\n",',
    '  "{\\"ok\\":true,\\"n\\":3}"), con)',
    'close(con); close(srv)'), srv_file)
  system2("r", srv_file, wait = FALSE)
  Sys.sleep(0.8)
  out <- oauth_request("tok", "http://127.0.0.1:1412/")
  expect_true(isTRUE(out$ok))
  expect_equal(out$n, 3L)
}
