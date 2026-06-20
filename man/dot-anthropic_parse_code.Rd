% tinyrox says don't edit this manually, but it can't stop you!
\name{.anthropic_parse_code}
\alias{.anthropic_parse_code}
\title{Parse the value pasted back from Claude's callback page}
\usage{
.anthropic_parse_code(x)
}
\description{
Claude's callback displays the code as \code{<code>#<state>}. Also accepts the
full redirected URL (\code{...callback?code=...&state=...}) or a bare code.
}
\keyword{internal}
