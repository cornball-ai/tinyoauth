# anthropic.R
# The Anthropic Claude (Claude Code) login route. A standard OAuth 2.0
# authorization-code grant with client-generated PKCE (S256), against Claude's
# public Claude Code client. Unlike the generic authcode flow, Claude's redirect
# lands on a hosted callback page that simply *displays* the code (as
# "<code>#<state>"), so this route is always manual-paste -- there is no loopback
# listener to catch -- and Claude's token endpoint speaks JSON rather than
# form-encoding. Reuses the generic primitives where it can (oauth_client,
# .as_token, oauth_expired, the cache) and adds the PKCE + JSON bits on top.

#' OAuth client for the Anthropic Claude (Claude Code) login flow
#'
#' A preconfigured [oauth_client] for Claude-subscription-backed access, carrying
#' Anthropic's authorize and token endpoints plus the Claude Code scope string.
#' The client id is Anthropic's public Claude Code identifier, not a secret.
#'
#' @return A \code{tinyoauth_client} with an extra \code{scope} field.
#' @examples
#' anthropic_claude_client()
#' @export
anthropic_claude_client <- function() {
    client <- oauth_client(
                           id = "9d1c250a-e61b-44d9-88ed-5944d1962f5e",
                           token_url = "https://console.anthropic.com/v1/oauth/token",
                           auth_url = "https://claude.ai/oauth/authorize",
                           redirect_uri = "https://console.anthropic.com/oauth/code/callback")
    client$scope <- "org:create_api_key user:profile user:inference"
    client
}

#' base64url-encode a raw vector (no padding)
#' @keywords internal
.b64url <- function(raw) {
    s <- jsonlite::base64_enc(raw)
    chartr("+/", "-_", sub("=+$", "", s))
}

#' Generate a PKCE verifier and its S256 challenge
#'
#' The verifier is a 64-char token from the unreserved PKCE alphabet (matching
#' the package's state-generation idiom); the challenge is the base64url-encoded
#' SHA-256 of the verifier's ASCII bytes.
#' @keywords internal
.anthropic_pkce <- function() {
    verifier <- paste(sample(c(0:9, letters, LETTERS), 64, replace = TRUE),
                      collapse = "")
    digestfn <- digest::digest
    challenge <- .b64url(digestfn(charToRaw(verifier), algo = "sha256",
                                  serialize = FALSE, raw = TRUE))
    list(verifier = verifier, challenge = challenge)
}

#' Build the Claude authorization URL (with PKCE and code=true)
#' @keywords internal
.anthropic_authorize_url <- function(client, pkce, state) {
    q <- .form_encode(list(code = "true", client_id = client$id,
                           response_type = "code",
                           redirect_uri = client$redirect_uri,
                           scope = client$scope,
                           code_challenge = pkce$challenge,
                           code_challenge_method = "S256", state = state))
    paste0(client$auth_url, "?", q)
}

#' POST a JSON body to an Anthropic OAuth endpoint and parse into a token
#'
#' Claude's token endpoint takes JSON (the generic [.token_request] form-encodes,
#' which Anthropic rejects), so this route needs its own POST. Reuses [.as_token].
#' @keywords internal
.anthropic_post_json <- function(url, body) {
    h <- curl::new_handle()
    curl::handle_setheaders(h, "Content-Type" = "application/json")
    curl::handle_setopt(h, post = TRUE,
                        postfields = jsonlite::toJSON(body, auto_unbox = TRUE))
    res <- curl::curl_fetch_memory(url, handle = h)
    parsed <- tryCatch(jsonlite::fromJSON(rawToChar(res$content)),
                       error = function(e) list())
    if (res$status_code >= 300L) {
        stop("anthropic: token request failed (HTTP ", res$status_code, "): ",
             parsed$error_description %||% parsed$error %||%
             rawToChar(res$content), call. = FALSE)
    }
    .as_token(parsed)
}

#' Exchange a Claude authorization code (with its PKCE verifier) for a token
#' @keywords internal
.anthropic_exchange <- function(client, code, state, verifier) {
    .anthropic_post_json(client$token_url,
                         list(grant_type = "authorization_code", code = code, state = state,
                              redirect_uri = client$redirect_uri, client_id = client$id,
                              code_verifier = verifier))
}

#' Refresh a Claude token (JSON refresh-token grant)
#' @keywords internal
.anthropic_refresh <- function(client, token) {
    rt <- token$refresh_token %||%
    stop("anthropic: token has no refresh_token", call. = FALSE)
    fresh <- .anthropic_post_json(client$token_url,
                                  list(grant_type = "refresh_token", refresh_token = rt,
                                       client_id = client$id))
    if (is.null(fresh$refresh_token)) {
        fresh$refresh_token <- rt
    }
    fresh
}

#' Parse the value pasted back from Claude's callback page
#'
#' Claude's callback displays the code as \code{<code>#<state>}. Also accepts the
#' full redirected URL (\code{...callback?code=...&state=...}) or a bare code.
#' @keywords internal
.anthropic_parse_code <- function(x) {
    x <- trimws(x)
    if (!nzchar(x)) {
        return(list())
    }
    if (grepl("#", x, fixed = TRUE) && !grepl("?", x, fixed = TRUE)) {
        parts <- strsplit(x, "#", fixed = TRUE)[[1L]]
        return(list(code = parts[1L],
                    state = if (length(parts) > 1L) parts[2L] else NULL))
    }
    .parse_redirect_input(x)
}

#' Run the Claude login flow end to end (display URL, paste code, exchange)
#' @keywords internal
.anthropic_login <- function(client, open_url = interactive()) {
    pkce <- .anthropic_pkce()
    state <- paste(sample(c(0:9, letters), 24, replace = TRUE), collapse = "")
    url <- .anthropic_authorize_url(client, pkce, state)
    message(
            "== Authorize Claude (manual paste) ==\n\n",
            "1. Open this URL in a browser logged in to your Claude account:\n\n",
            "     ", url, "\n\n",
            "2. Approve access.\n",
            "3. The page shows an authorization code of the form CODE#STATE.\n",
            "   Copy the whole thing and paste it at the prompt below.\n")
    if (isTRUE(open_url)) {
        try(utils::browseURL(url), silent = TRUE)
    }
    parsed <- .anthropic_parse_code(readline("Paste the code (CODE#STATE): "))
    if (is.null(parsed$code) || !nzchar(parsed$code)) {
        stop("anthropic: no authorization code found in what you pasted. ",
             "Expected CODE#STATE (or the redirected callback URL).",
             call. = FALSE)
    }
    if (!is.null(parsed$state) && nzchar(parsed$state) &&
        !identical(parsed$state, state)) {
        stop("anthropic: state mismatch -- possible CSRF; aborting",
             call. = FALSE)
    }
    .anthropic_exchange(client, parsed$code, parsed$state %||% state,
                        pkce$verifier)
}

#' Get a valid Anthropic Claude token, using the cache and refreshing as needed
#'
#' The Claude analogue of [oauth_token]: returns a cached token if still valid,
#' refreshes it if expired and a refresh token is available, otherwise runs the
#' manual-paste login flow. The token is written back to \code{cache}.
#'
#' These are subscription credentials minted for Claude Code; using them is
#' subject to Anthropic's terms for that product.
#'
#' @param cache Cache file path, or \code{NULL} to disable caching. Defaults to
#'   [oauth_cache_path] for the Claude client.
#' @param open_url Open the authorization URL automatically (default: interactive
#'   sessions only).
#' @param login Run the login flow when no usable cached/refreshable token exists
#'   (default \code{TRUE}). Pass \code{FALSE} to get the cached (and
#'   refreshed-if-needed) token or \code{NULL}, without ever prompting -- useful
#'   inside a request path where an interactive login would be wrong.
#' @return A \code{tinyoauth_token} with \code{access_token},
#'   \code{refresh_token}, and \code{expires_at}; or \code{NULL} when
#'   \code{login} is \code{FALSE} and no usable token is cached.
#' @examples
#' \dontrun{
#' tok <- oauth_token_anthropic()
#' curl::handle_setheaders(curl::new_handle(),
#'                         Authorization = oauth_bearer(tok),
#'                         "anthropic-beta" = "oauth-2025-04-20")
#' }
#' @export
oauth_token_anthropic <- function(cache = oauth_cache_path(anthropic_claude_client()),
                                  open_url = interactive(), login = TRUE) {
    client <- anthropic_claude_client()
    tok <- if (!is.null(cache) && file.exists(cache)) {
        tryCatch(readRDS(cache), error = function(e) NULL)
    } else {
        NULL
    }

    if (!is.null(tok) && oauth_expired(tok) && !is.null(tok$refresh_token)) {
        tok <- tryCatch(.anthropic_refresh(client, tok),
                        error = function(e) NULL)
    }

    need_new <- is.null(tok) || is.null(tok$access_token) ||
    (oauth_expired(tok) && is.null(tok$refresh_token))
    if (need_new) {
        if (!login) {
            return(NULL)
        }
        tok <- .anthropic_login(client, open_url = open_url)
    }

    if (!is.null(cache) && !is.null(tok)) {
        dir.create(dirname(cache), recursive = TRUE, showWarnings = FALSE)
        saveRDS(tok, cache)
    }
    tok
}
