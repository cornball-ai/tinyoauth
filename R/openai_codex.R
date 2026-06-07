# openai_codex.R
# The ChatGPT/Codex device-login route. This is NOT the RFC 8628 device grant:
# OpenAI's poll endpoint returns an authorization_code plus a PKCE code_verifier
# that you then exchange at the token endpoint, rather than returning tokens
# directly. So it gets a dedicated route here that reuses the generic primitives
# (oauth_client, .token_request, tinyoauth_token, oauth_refresh, the cache).
#
# Route adapted from Sounkou Mahamane Toure's llm.api PR #20, which proved the
# flow; tinyoauth adds token caching/refresh on top.

#' OAuth client for the OpenAI Codex (ChatGPT) device-login flow
#'
#' A preconfigured [oauth_client] for ChatGPT-subscription-backed Codex access,
#' carrying OpenAI's device-authorization endpoints alongside the standard token
#' endpoint. The client id is OpenAI's public native-app identifier, not a
#' secret.
#'
#' @return A \code{tinyoauth_client} with extra \code{device_usercode_url},
#'   \code{device_token_url}, and \code{verification_uri} fields.
#' @examples
#' openai_codex_client()
#' @export
openai_codex_client <- function() {
    base <- "https://auth.openai.com"
    client <- oauth_client(
                           id = "app_EMoamEEZ73f0CkXaXp7hrann",
                           token_url = paste0(base, "/oauth/token"),
                           redirect_uri = paste0(base, "/deviceauth/callback"))
    client$device_usercode_url <- paste0(base, "/api/accounts/deviceauth/usercode")
    client$device_token_url <- paste0(base, "/api/accounts/deviceauth/token")
    client$verification_uri <- paste0(base, "/codex/device")
    client
}

#' POST a JSON body and parse the JSON response
#'
#' The device endpoints take JSON (the token endpoint takes form-encoding, which
#' is what [.token_request] handles).
#' @keywords internal
.codex_post_json <- function(url, body) {
    h <- curl::new_handle()
    curl::handle_setheaders(h, "Content-Type" = "application/json")
    curl::handle_setopt(h, post = TRUE,
                        postfields = jsonlite::toJSON(body, auto_unbox = TRUE))
    res <- curl::curl_fetch_memory(url, handle = h)
    parsed <- tryCatch(jsonlite::fromJSON(rawToChar(res$content)),
                       error = function(e) list())
    list(status = res$status_code, body = parsed, raw = rawToChar(res$content))
}

#' Start the device-authorization flow: get a user code to display
#'
#' @param post JSON-POST function, injectable for testing.
#' @keywords internal
.codex_device_start <- function(client, post = .codex_post_json) {
    r <- post(client$device_usercode_url, list(client_id = client$id))
    if (r$status >= 300L || is.null(r$body$user_code)) {
        stop("openai_codex: could not start device authorization (HTTP ",
             r$status, "): ", r$raw, call. = FALSE)
    }
    r$body
}

#' Classify a device-token poll response
#'
#' Returns one of \code{"ok"} (authorization granted), \code{"pending"} (keep
#' waiting), \code{"slow_down"} (back off), or \code{"error"} (give up).
#' @keywords internal
.codex_poll_classify <- function(status, body) {
    if (status < 300L && !is.null(body$authorization_code)) {
        return("ok")
    }
    err <- body$error %||% body$error_code %||% ""
    if (identical(err, "slow_down")) {
        return("slow_down")
    }
    if (identical(err, "deviceauth_authorization_pending") ||
        identical(err, "authorization_pending")) {
        return("pending")
    }
    "error"
}

#' Poll the device-token endpoint until the user authorizes (or we time out)
#'
#' @param sleep Sleep function, injectable for testing.
#' @param post JSON-POST function, injectable for testing.
#' @keywords internal
.codex_device_poll <- function(client, device, timeout = 600, sleep = Sys.sleep,
                               post = .codex_post_json) {
    interval <- as.numeric(device$interval %||% 5)
    deadline <- Sys.time() + timeout
    repeat {
        if (Sys.time() > deadline) {
            stop("openai_codex: device authorization timed out", call. = FALSE)
        }
        sleep(interval)
        r <- post(client$device_token_url,
                  list(device_auth_id = device$device_auth_id,
                       user_code = device$user_code))
        status <- .codex_poll_classify(r$status, r$body)
        if (identical(status, "ok")) {
            return(r$body)
        } else if (identical(status, "slow_down")) {
            interval <- interval + 5
        } else if (identical(status, "error")) {
            stop("openai_codex: device authorization failed: ",
                 r$body$error %||% r$raw, call. = FALSE)
        }
        # "pending" falls through and loops
    }
}

#' Exchange the device authorization code (with its PKCE verifier) for a token
#' @keywords internal
.codex_exchange <- function(client, code, verifier) {
    .token_request(client, list(grant_type = "authorization_code",
                                code = code, code_verifier = verifier,
                                redirect_uri = client$redirect_uri))
}

#' Run the device-login flow end to end (display code, wait, exchange)
#' @keywords internal
.codex_login <- function(client, open_url = interactive(), timeout = 600) {
    device <- .codex_device_start(client)
    message("openai_codex: to authorize, open\n  ", client$verification_uri,
            "\nand enter the code: ", device$user_code)
    if (isTRUE(open_url)) {
        try(utils::browseURL(client$verification_uri), silent = TRUE)
    }
    auth <- .codex_device_poll(client, device, timeout = timeout)
    .codex_exchange(client, auth$authorization_code, auth$code_verifier)
}

#' Attach the ChatGPT account id (from the access-token JWT) to a token
#' @keywords internal
.codex_finalize <- function(token) {
    if (!is.null(token)) {
        token$account_id <- openai_codex_account_id(token)
    }
    token
}

#' Extract the ChatGPT account id from a Codex token
#'
#' Reads the \code{chatgpt_account_id} claim that OpenAI nests under
#' \code{https://api.openai.com/auth} in the access-token JWT.
#'
#' @param token A \code{tinyoauth_token} (or raw access-token string).
#' @return The account id string, or \code{NULL} if absent.
#' @export
openai_codex_account_id <- function(token) {
    payload <- oauth_jwt_payload(token)
    if (is.null(payload)) {
        return(NULL)
    }
    auth <- payload[["https://api.openai.com/auth"]]
    if (is.null(auth)) {
        return(NULL)
    }
    auth$chatgpt_account_id
}

#' Get a valid OpenAI Codex token, using the cache and refreshing as needed
#'
#' The Codex analogue of [oauth_token]: returns a cached token if still valid,
#' refreshes it if expired and a refresh token is available, otherwise runs the
#' device-login flow. The token carries an extra \code{account_id} field (the
#' ChatGPT account id) and is written back to \code{cache}.
#'
#' @param cache Cache file path, or \code{NULL} to disable caching. Defaults to
#'   [oauth_cache_path] for the Codex client.
#' @param open_url Open the verification URL automatically (default: interactive
#'   sessions only).
#' @param timeout Seconds to wait for device authorization (default 600).
#' @return A \code{tinyoauth_token} with \code{access_token}, \code{refresh_token},
#'   \code{expires_at}, and \code{account_id}.
#' @examples
#' \dontrun{
#' tok <- oauth_token_openai_codex()
#' curl::handle_setheaders(curl::new_handle(),
#'                         Authorization = oauth_bearer(tok),
#'                         "chatgpt-account-id" = tok$account_id)
#' }
#' @export
oauth_token_openai_codex <- function(cache = oauth_cache_path(openai_codex_client()),
                                     open_url = interactive(), timeout = 600) {
    client <- openai_codex_client()
    tok <- if (!is.null(cache) && file.exists(cache)) {
        tryCatch(readRDS(cache), error = function(e) NULL)
    } else {
        NULL
    }

    if (!is.null(tok) && oauth_expired(tok) && !is.null(tok$refresh_token)) {
        tok <- tryCatch(.codex_finalize(oauth_refresh(client, tok)),
                        error = function(e) NULL)
    }

    need_new <- is.null(tok) || is.null(tok$access_token) ||
    (oauth_expired(tok) && is.null(tok$refresh_token))
    if (need_new) {
        tok <- .codex_finalize(.codex_login(client, open_url = open_url,
                                            timeout = timeout))
    }

    if (!is.null(cache)) {
        dir.create(dirname(cache), recursive = TRUE, showWarnings = FALSE)
        saveRDS(tok, cache)
    }
    tok
}
