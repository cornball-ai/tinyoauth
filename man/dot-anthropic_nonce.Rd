% tinyrox says don't edit this manually, but it can't stop you!
\name{.anthropic_nonce}
\alias{.anthropic_nonce}
\title{A random base64url token of \code{nbytes} entropy}
\usage{
.anthropic_nonce(nbytes = 32L)
}
\description{
32 bytes encodes to a 43-char base64url string, matching the format the
Claude Code client uses for both the PKCE verifier and the OAuth state.
}
\keyword{internal}
