# request.R
# The token endpoint request: form-encode the grant fields, attach HTTP Basic
# client auth, POST via curl, and parse the JSON into a token.

#' Drop NULL list elements
#' @keywords internal
.drop_null <- function(x) x[!vapply(x, is.null, logical(1))]

#' Form-encode a named list as application/x-www-form-urlencoded, dropping NULLs
#' @keywords internal
.form_encode <- function(fields) {
    fields <- .drop_null(fields)
    if (length(fields) == 0) {
        return("")
    }
    paste(vapply(names(fields), function(k) {
        paste0(curl::curl_escape(k), "=",
               curl::curl_escape(as.character(fields[[k]])))
    }, character(1)), collapse = "&")
}

#' HTTP Basic authorization header value for client credentials
#' @keywords internal
.basic_auth <- function(id, secret) {
    paste("Basic",
          gsub("\n", "", jsonlite::base64_enc(paste0(id, ":", secret))))
}

#' POST a grant to the token endpoint and parse the result
#' @keywords internal
.token_request <- function(client, fields) {
    h <- curl::new_handle()
    hdrs <- c("Content-Type" = "application/x-www-form-urlencoded")
    if (!is.null(client$secret)) {
        hdrs <- c(hdrs, Authorization = .basic_auth(client$id, client$secret))
    } else {
        fields$client_id <- client$id
    }
    do.call(curl::handle_setheaders, c(list(h), as.list(hdrs)))
    curl::handle_setopt(h, postfields = .form_encode(fields))

    res <- curl::curl_fetch_memory(client$token_url, handle = h)
    body <- tryCatch(jsonlite::fromJSON(rawToChar(res$content)),
                     error = function(e) list())
    if (res$status_code >= 300L) {
        stop("token request failed (HTTP ", res$status_code, "): ",
             body$error_description %||% body$error %||% rawToChar(res$content),
             call. = FALSE)
    }
    .as_token(body)
}

#' Build a tinyoauth_token from a parsed token response
#' @keywords internal
.as_token <- function(body) {
    structure(list(
                   access_token = body$access_token,
                   token_type = body$token_type %||% "Bearer",
                   refresh_token = body$refresh_token,
                   scope = body$scope,
                   expires_at = if (!is.null(body$expires_in)) {
                Sys.time() + as.numeric(body$expires_in)
            } else {
                NULL
            }
        ), class = "tinyoauth_token")
}
