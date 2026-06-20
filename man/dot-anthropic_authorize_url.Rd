% tinyrox says don't edit this manually, but it can't stop you!
\name{.anthropic_authorize_url}
\alias{.anthropic_authorize_url}
\title{Build the Claude authorization URL (with PKCE)}
\usage{
.anthropic_authorize_url(client, pkce, state)
}
\description{
The \code{code=true} parameter selects the manual flow, where the callback
page displays the authorization code (as \code{<code>#<state>}) for pasting.
}
\keyword{internal}
