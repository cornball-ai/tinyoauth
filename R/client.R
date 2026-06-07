# client.R
# An OAuth 2.0 client: the per-application config (id/secret) plus the
# provider's token and authorize endpoints.

#' Define an OAuth 2.0 client
#'
#' @param id Client (application) id.
#' @param secret Client secret, or NULL for public clients.
#' @param token_url The provider's token endpoint.
#' @param auth_url The provider's authorization endpoint (needed for the
#'   authorization-code grant; omit for client-credentials only).
#' @param redirect_uri Redirect URI registered with the provider. Use a
#'   loopback IP literal over http (\code{127.0.0.1}); many providers reject
#'   \code{localhost}.
#' @return A \code{tinyoauth_client} object.
#' @examples
#' spotify <- oauth_client(
#'   id = "your_id", secret = "your_secret",
#'   token_url = "https://accounts.spotify.com/api/token",
#'   auth_url  = "https://accounts.spotify.com/authorize")
#' @export
oauth_client <- function(id, secret = NULL, token_url, auth_url = NULL,
                         redirect_uri = "http://127.0.0.1:1410/") {
    if (missing(id) || !nzchar(id)) {
        stop("oauth_client(): 'id' is required", call. = FALSE)
    }
    if (missing(token_url) || !nzchar(token_url)) {
        stop("oauth_client(): 'token_url' is required", call. = FALSE)
    }
    structure(
              list(id = id, secret = secret, token_url = token_url,
                   auth_url = auth_url, redirect_uri = redirect_uri),
              class = "tinyoauth_client")
}

#' @export
print.tinyoauth_client <- function(x, ...) {
    cat("<tinyoauth_client>\n")
    cat("  id:        ", x$id, "\n", sep = "")
    cat("  token_url: ", x$token_url, "\n", sep = "")
    cat("  auth_url:  ", x$auth_url %||% "(none)", "\n", sep = "")
    cat("  redirect:  ", x$redirect_uri, "\n", sep = "")
    invisible(x)
}

