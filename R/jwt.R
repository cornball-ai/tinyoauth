# jwt.R
# Read-only decode of a JWT payload. OAuth providers often pack useful claims
# (account ids, scopes) into the access token itself; this exposes them without
# pulling in a JWT/crypto dependency. No signature verification -- this is for
# reading claims you already trust, not validating tokens.

#' Decode a JWT payload
#'
#' Base64url-decodes the payload (middle) segment of a JSON Web Token and parses
#' it as JSON. Does not verify the signature; use only on tokens you already
#' trust (e.g. one the provider just issued you).
#'
#' @param x A JWT string, or a \code{tinyoauth_token} (its \code{access_token}
#'   is used).
#' @return The decoded payload as a named list, or \code{NULL} if \code{x} has
#'   no usable JWT.
#' @examples
#' # A toy token: header.payload.signature, payload = {"sub":"abc"}
#' payload <- jsonlite::base64_enc(charToRaw('{"sub":"abc"}'))
#' jwt <- paste("x", gsub("=", "", payload), "y", sep = ".")
#' oauth_jwt_payload(jwt)$sub
#' @export
oauth_jwt_payload <- function(x) {
    jwt <- if (inherits(x, "tinyoauth_token")) {
        x$access_token
    } else {
        x
    }
    if (is.null(jwt) || !is.character(jwt) || length(jwt) != 1L) {
        return(NULL)
    }
    parts <- strsplit(jwt, ".", fixed = TRUE)[[1]]
    if (length(parts) < 2L || !nzchar(parts[2])) {
        return(NULL)
    }
    # base64url -> base64, then pad to a multiple of 4. Strip any whitespace
    # first (base64url has none; some encoders line-wrap their output).
    seg <- gsub("[[:space:]]", "", parts[2])
    seg <- chartr("-_", "+/", seg)
    pad <- nchar(seg) %% 4L
    if (pad > 0L) {
        seg <- paste0(seg, strrep("=", 4L - pad))
    }
    raw <- tryCatch(jsonlite::base64_dec(seg), error = function(e) NULL)
    if (is.null(raw)) {
        return(NULL)
    }
    tryCatch(jsonlite::fromJSON(rawToChar(raw)), error = function(e) NULL)
}

