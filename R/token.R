# token.R
# Token grants that don't need a browser: client-credentials and refresh, plus
# small helpers for using and inspecting tokens.

#' Fetch a token via the client-credentials grant
#'
#' App-only access (no user context).
#'
#' @param client A [oauth_client].
#' @return A \code{tinyoauth_token}.
#' @examples
#' \dontrun{
#' tok <- oauth_token_client(spotify)
#' }
#' @export
oauth_token_client <- function(client) {
    .token_request(client, list(grant_type = "client_credentials"))
}

#' Refresh an access token
#'
#' @param client A [oauth_client].
#' @param token A \code{tinyoauth_token} carrying a refresh token.
#' @return A refreshed \code{tinyoauth_token}. Providers that omit a new refresh
#'   token on refresh keep the existing one.
#' @examples
#' \dontrun{
#' tok <- oauth_refresh(spotify, tok)
#' }
#' @export
oauth_refresh <- function(client, token) {
    rt <- token$refresh_token %||%
    stop("oauth_refresh(): token has no refresh_token", call. = FALSE)
    fresh <- .token_request(client, list(grant_type = "refresh_token",
            refresh_token = rt))
    if (is.null(fresh$refresh_token)) {
        fresh$refresh_token <- rt
    }
    fresh
}

#' Is a token expired?
#'
#' @param token A \code{tinyoauth_token}.
#' @param leeway Seconds of slack before the hard expiry (default 60).
#' @return \code{TRUE} if expired (or within \code{leeway} of it); \code{FALSE}
#'   when there is no expiry recorded.
#' @export
oauth_expired <- function(token, leeway = 60) {
    if (is.null(token$expires_at)) {
        return(FALSE)
    }
    Sys.time() >= token$expires_at - leeway
}

#' Authorization header value for a token
#'
#' @param token A \code{tinyoauth_token} or a raw access-token string.
#' @return A string like \code{"Bearer abc123"} for use as an HTTP
#'   \code{Authorization} header.
#' @examples
#' \dontrun{
#' h <- curl::new_handle()
#' curl::handle_setheaders(h, Authorization = oauth_bearer(tok))
#' }
#' @export
oauth_bearer <- function(token) {
    if (inherits(token, "tinyoauth_token")) {
        at <- token$access_token
    } else {
        at <- token
    }
    paste("Bearer", at)
}

#' @export
print.tinyoauth_token <- function(x, ...) {
    cat("<tinyoauth_token>\n")
    cat("  access_token: ", substr(x$access_token, 1, 12), "...\n", sep = "")
    cat("  refresh:      ",
        if (is.null(x$refresh_token)) {
            "no"
        } else {
            "yes"
        }, "\n", sep = "")
    cat("  expires_at:   ",
        if (is.null(x$expires_at)) {
            "(none)"
        } else {
            format(x$expires_at)
        }, "\n", sep = "")
    invisible(x)
}

