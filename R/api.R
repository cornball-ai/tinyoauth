# api.R
# A thin authenticated request: take a token, hit a JSON endpoint with a Bearer
# header, retry transient failures, and parse the result. The "now use your
# token" companion to the grant functions -- not a general HTTP client.

#' Fetch with a few retries on transport errors / 5xx
#' @keywords internal
.fetch_retry <- function(url, handle, times = 3L) {
    res <- NULL
    for (i in seq_len(times)) {
        res <- tryCatch(curl::curl_fetch_memory(url, handle = handle),
                        error = function(e) NULL)
        if (!is.null(res) && res$status_code < 500L) {
            return(res)
        }
        Sys.sleep(min(2 ^ (i - 1L), 5L))
    }
    if (is.null(res)) {
        stop("request failed (no response): ", url, call. = FALSE)
    }
    res
}

#' Make an authenticated request
#'
#' Sends an HTTP request with the token as a Bearer header, retrying transient
#' failures, and parses a JSON response. A convenience over building a curl
#' handle by hand; for anything exotic, use [oauth_bearer] with curl directly.
#'
#' @param token A \code{tinyoauth_token}, a (legacy) httr token, or a raw
#'   access-token string.
#' @param url Endpoint URL.
#' @param method HTTP method (default "GET").
#' @param query Optional named list of query parameters.
#' @param body Optional R object sent as a JSON body.
#' @param headers Optional named character vector of extra headers.
#' @param flatten Passed to \code{jsonlite::fromJSON} (default FALSE).
#' @param retries Attempts on transport errors / HTTP 5xx (default 3).
#' @return Parsed JSON, or invisibly \code{NULL} for an empty response body.
#'   Non-2xx responses raise an error carrying the status and body.
#' @examples
#' \dontrun{
#' oauth_request(tok, "https://api.spotify.com/v1/me")
#' }
#' @export
oauth_request <- function(token, url, method = "GET", query = NULL,
                          body = NULL, headers = NULL, flatten = FALSE,
                          retries = 3L) {
    h <- curl::new_handle()
    hdr <- c(Authorization = oauth_bearer(token), headers)
    if (!is.null(body)) {
        hdr <- c(hdr, "Content-Type" = "application/json")
    }
    do.call(curl::handle_setheaders, c(list(h), as.list(hdr)))
    curl::handle_setopt(h, customrequest = method)
    if (!is.null(body)) {
        curl::handle_setopt(h,
                            postfields = jsonlite::toJSON(body, auto_unbox = TRUE,
                null = "null"))
    }

    qs <- .form_encode(query)
    if (nzchar(qs)) {
        full <- paste0(url, "?", qs)
    } else {
        full <- url
    }
    res <- .fetch_retry(full, h, retries)
    txt <- rawToChar(res$content)
    if (res$status_code >= 300L) {
        stop("HTTP ", res$status_code,
            if (nzchar(trimws(txt))) paste0(": ", txt) else "", call. = FALSE)
    }
    if (!nzchar(trimws(txt))) {
        return(invisible(NULL))
    }
    jsonlite::fromJSON(txt, flatten = flatten)
}
