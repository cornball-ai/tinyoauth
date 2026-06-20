# import.R
# Migration on-ramp: read an httr `.httr-oauth` cache and convert it into a
# tinyoauth client + token, so existing authorizations carry over without a
# fresh browser login. Reading the file needs no httr (just readRDS + field
# access on the stored object).

#' Import an httr `.httr-oauth` cache into tinyoauth
#'
#' Reads a token cached by \pkg{httr}'s \code{oauth2.0_token()} and returns a
#' tinyoauth client and token built from it -- the app credentials, endpoints,
#' and (crucially) the refresh token. This lets a package migrating off
#' \pkg{httr} reuse an existing authorization instead of forcing users to log in
#' again.
#'
#' The imported access token is marked expired, since httr's cached access token
#' is usually stale: the durable credential is the refresh token. Pass the result
#' to [oauth_refresh] or [oauth_token] to mint a fresh access token.
#'
#' @param path Path to the httr cache (default \code{".httr-oauth"}).
#' @param which Which cached token to import when the file holds several
#'   (1-based; default 1).
#' @return A list with \code{client} (a [oauth_client]) and \code{token} (a
#'   \code{tinyoauth_token}).
#' @examples
#' \dontrun{
#' imported <- oauth_import_httr("~/project/.httr-oauth")
#' token <- oauth_refresh(imported$client, imported$token)
#' }
#' @export
oauth_import_httr <- function(path = ".httr-oauth", which = 1L) {
    if (!file.exists(path)) {
        stop("no httr cache at ", path, call. = FALSE)
    }
    obj <- readRDS(path)
    if (inherits(obj, "Token2.0")) {
        toks <- list(obj)
    } else {
        toks <- obj
    }
    toks <- Filter(function(t) inherits(t, "Token2.0"), toks)
    if (length(toks) == 0) {
        stop("no httr Token2.0 found in ", path, call. = FALSE)
    }
    if (which < 1 || which > length(toks)) {
        stop(path, " holds ", length(toks),
             " token(s); 'which' must be 1..", length(toks), call. = FALSE)
    }
    ht <- toks[[which]]
    cr <- ht$credentials

    client <- oauth_client(
                           id = ht$app$key, secret = ht$app$secret,
                           token_url = ht$endpoint$access,
                           auth_url = ht$endpoint$authorize,
                           redirect_uri = ht$app$redirect_uri %||% "http://127.0.0.1:1410/")

    token <- structure(list(
                            access_token = cr$access_token,
                            token_type = cr$token_type %||% "Bearer",
                            refresh_token = cr$refresh_token,
                            scope = if (length(cr$scope)) {
                paste(cr$scope, collapse = " ")
            } else {
                NULL
            },
                            # httr's cached access token is usually stale; force a refresh on first use.
                            expires_at = Sys.time() - 1
        ), class = "tinyoauth_token")

    list(client = client, token = token)
}
