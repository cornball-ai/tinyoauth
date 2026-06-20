% tinyrox says don't edit this manually, but it can't stop you!
\name{.anthropic_pkce}
\alias{.anthropic_pkce}
\title{Generate a PKCE verifier and its S256 challenge}
\usage{
.anthropic_pkce()
}
\description{
The verifier is a 64-char token from the unreserved PKCE alphabet (matching
the package's state-generation idiom); the challenge is the base64url-encoded
SHA-256 of the verifier's ASCII bytes.
}
\keyword{internal}
