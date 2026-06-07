#' tinyoauth: Minimal OAuth 2.0 for R
#'
#' A dependency-light OAuth 2.0 client: the client-credentials and
#' authorization-code grants (with token refresh), built on \pkg{curl} and
#' \pkg{jsonlite} plus base R's \code{serverSocket()} for the redirect listener.
#' No \pkg{httr}/\pkg{httr2}.
#'
#' @importFrom curl new_handle handle_setheaders handle_setopt curl_fetch_memory curl_escape
#' @importFrom jsonlite fromJSON base64_enc
#' @importFrom utils browseURL
#' @importFrom tools R_user_dir
#' @keywords internal
"_PACKAGE"

# Base R gained `%||%` in 4.4; define our own so we can support R (>= 4.0).
`%||%` <- function(a, b) if (is.null(a)) b else a

