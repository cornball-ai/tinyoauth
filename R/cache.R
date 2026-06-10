# cache.R
# Token caching + the high-level "just give me a valid token" entry point.
# Cache lives under tools::R_user_dir() (CRAN-compliant; never the home dir).

#' Default on-disk cache path for a client's token
#'
#' @param client A [oauth_client].
#' @return Path to the token cache file under \code{tools::R_user_dir}.
#' @examples
#' client <- oauth_client("my_app", token_url = "https://example.com/token")
#' oauth_cache_path(client)
#' @export
oauth_cache_path <- function(client) {
    key <- gsub("[^A-Za-z0-9]", "_", client$id)
    file.path(tools::R_user_dir("tinyoauth", "cache"), paste0(key, ".rds"))
}

#' Get a valid token, using the cache and refreshing as needed
#'
#' Returns a cached token if still valid; refreshes it if expired and a refresh
#' token is available; otherwise runs the authorization-code flow. The result is
#' written back to \code{cache}.
#'
#' @param client A [oauth_client].
#' @param scope Optional space-delimited scope string (for first authorization).
#' @param cache Cache file path, or \code{NULL} to disable caching. Defaults to
#'   [oauth_cache_path].
#' @param ... Passed to [oauth_token_authcode] (e.g. \code{port},
#'   \code{open_browser}).
#' @return A valid \code{tinyoauth_token}.
#' @examples
#' \dontrun{
#' tok <- oauth_token(spotify, scope = "user-read-email")
#' }
#' @export
oauth_token <- function(client, scope = NULL,
                        cache = oauth_cache_path(client), ...) {
    tok <- if (!is.null(cache) && file.exists(cache)) {
        tryCatch(readRDS(cache), error = function(e) NULL)
    } else {
        NULL
    }

    if (!is.null(tok) && oauth_expired(tok) && !is.null(tok$refresh_token)) {
        tok <- tryCatch(oauth_refresh(client, tok), error = function(e) NULL)
    }

    need_new <- is.null(tok) || is.null(tok$access_token) ||
    (oauth_expired(tok) && is.null(tok$refresh_token))
    if (need_new) {
        tok <- oauth_token_authcode(client, scope = scope, ...)
    }

    if (!is.null(cache)) {
        dir.create(dirname(cache), recursive = TRUE, showWarnings = FALSE)
        saveRDS(tok, cache)
    }
    tok
}

