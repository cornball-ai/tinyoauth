% tinyrox says don't edit this manually, but it can't stop you!
\name{.parse_redirect_input}
\alias{.parse_redirect_input}
\title{Parse a pasted redirect URL (or bare code) into query parameters}
\usage{
.parse_redirect_input(x)
}
\description{
Accepts the full \code{http://127.0.0.1:.../?code=...&state=...} address the
browser landed on, a bare \code{code=...&state=...} query string, or just the
code value on its own. Used by the \code{manual = TRUE} (no-listener) path.
}
\keyword{internal}
