% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_jwt_payload}
\alias{oauth_jwt_payload}
\title{Decode a JWT payload}
\usage{
oauth_jwt_payload(x)
}
\arguments{
\item{x}{A JWT string, or a \code{tinyoauth_token} (its \code{access_token}
is used).}
}
\value{
The decoded payload as a named list, or \code{NULL} if \code{x} has
  no usable JWT.
}
\description{
Base64url-decodes the payload (middle) segment of a JSON Web Token and parses
it as JSON. Does not verify the signature; use only on tokens you already
trust (e.g. one the provider just issued you).
}
\examples{
# A toy token: header.payload.signature, payload = {"sub":"abc"}
payload <- jsonlite::base64_enc(charToRaw('{"sub":"abc"}'))
jwt <- paste("x", gsub("=", "", payload), "y", sep = ".")
oauth_jwt_payload(jwt)$sub
}
