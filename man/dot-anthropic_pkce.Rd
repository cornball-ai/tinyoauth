% tinyrox says don't edit this manually, but it can't stop you!
\name{.anthropic_pkce}
\alias{.anthropic_pkce}
\title{Generate a PKCE verifier and its S256 challenge}
\usage{
.anthropic_pkce()
}
\description{
The verifier is a 43-char base64url token (32 bytes of entropy, matching the
Claude Code client); the challenge is the base64url-encoded SHA-256 of the
verifier's ASCII bytes.
}
\keyword{internal}
