# authcode.R
# Authorization-code grant. Build the authorize URL, capture the redirect with
# a one-shot base-R serverSocket() listener (no httpuv), and exchange the code.

#' Build an authorization URL
#'
#' @param client A [oauth_client] with an \code{auth_url}.
#' @param scope Optional space-delimited scope string.
#' @param state Optional opaque state for CSRF protection.
#' @return The authorization URL to open in a browser.
#' @examples
#' oauth_authorize_url(
#'   oauth_client("id", token_url = "https://x/token",
#'                auth_url = "https://x/authorize"),
#'   scope = "user-read-email")
#' @export
oauth_authorize_url <- function(client, scope = NULL, state = NULL) {
    if (is.null(client$auth_url)) {
        stop("oauth_authorize_url(): client has no auth_url", call. = FALSE)
    }
    q <- .form_encode(list(client_id = client$id, response_type = "code",
                           redirect_uri = client$redirect_uri, scope = scope,
                           state = state))
    paste0(client$auth_url, "?", q)
}

#' Parse the query parameters from an HTTP request line
#' @keywords internal
.parse_request_query <- function(req_line) {
    qs <- sub("^\\S+\\s+\\S*?\\?([^ ]*)\\s.*$", "\\1", req_line)
    if (identical(qs, req_line) || !nzchar(qs)) {
        return(list())
    }
    pairs <- strsplit(strsplit(qs, "&", fixed = TRUE)[[1]], "=", fixed = TRUE)
    out <- lapply(pairs, function(p) if (length(p) > 1) {
            utils::URLdecode(p[2])
        } else {
            ""
        })
    stats::setNames(out, vapply(pairs, `[`, character(1), 1))
}

#' Catch a single OAuth redirect on a loopback port
#'
#' Opens a one-shot \code{serverSocket()} listener, accepts the browser
#' redirect, replies with a small page, and returns the parsed query.
#'
#' @param port Loopback port to listen on (must match the redirect URI).
#' @param timeout Seconds to wait for the redirect.
#' @return Named list of query parameters from the redirect.
#' @keywords internal
.listen_for_redirect <- function(port = 1410L, timeout = 120) {
    srv <- serverSocket(port)
    on.exit(close(srv), add = TRUE)
    con <- socketAccept(srv, blocking = TRUE, open = "r+", timeout = timeout)
    on.exit(close(con), add = TRUE)
    req <- readLines(con, n = 1, warn = FALSE)
    writeLines(paste0("HTTP/1.1 200 OK\r\nContent-Type: text/html\r\n",
                      "Connection: close\r\n\r\n",
                      "<html><body><h3>Authorized. You can close this tab.</h3>",
                      "</body></html>"), con)
    if (!length(req) || !nzchar(req)) {
        stop("no redirect received", call. = FALSE)
    }
    .parse_request_query(req)
}

#' Exchange an authorization code for a token
#'
#' @param client A [oauth_client].
#' @param code The authorization code from the redirect.
#' @return A \code{tinyoauth_token}.
#' @export
oauth_exchange_code <- function(client, code) {
    .token_request(client, list(grant_type = "authorization_code",
                                code = code,
                                redirect_uri = client$redirect_uri))
}

#' Run the authorization-code flow end to end
#'
#' Prints (and optionally opens) the authorization URL, waits for the redirect
#' on a loopback listener, verifies \code{state}, and exchanges the code.
#'
#' @param client A [oauth_client] with an \code{auth_url}.
#' @param scope Optional space-delimited scope string.
#' @param port Loopback port for the listener; must match the port in
#'   \code{client$redirect_uri} (default 1410).
#' @param open_browser Open the URL automatically (default: interactive only).
#' @param timeout Seconds to wait for the redirect.
#' @return A \code{tinyoauth_token} (with a refresh token, when the provider
#'   issues one).
#' @examples
#' \dontrun{
#' tok <- oauth_token_authcode(spotify, scope = "user-read-email")
#' }
#' @export
oauth_token_authcode <- function(client, scope = NULL, port = 1410L,
                                 open_browser = interactive(), timeout = 120) {
    state <- paste(sample(c(0:9, letters), 24, replace = TRUE), collapse = "")
    url <- oauth_authorize_url(client, scope = scope, state = state)
    message("Open this URL to authorize:\n  ", url)
    if (isTRUE(open_browser)) {
        try(utils::browseURL(url), silent = TRUE)
    }
    q <- .listen_for_redirect(port = port, timeout = timeout)
    if (!is.null(q$error)) {
        stop("authorization failed: ", q$error, call. = FALSE)
    }
    if (is.null(q$code)) {
        stop("no authorization code in redirect", call. = FALSE)
    }
    if (!is.null(q$state) && !identical(q$state, state)) {
        stop("state mismatch -- possible CSRF; aborting", call. = FALSE)
    }
    oauth_exchange_code(client, q$code)
}

