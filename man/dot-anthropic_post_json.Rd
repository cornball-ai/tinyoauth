% tinyrox says don't edit this manually, but it can't stop you!
\name{.anthropic_post_json}
\alias{.anthropic_post_json}
\title{POST a JSON body to an Anthropic OAuth endpoint and parse into a token}
\usage{
.anthropic_post_json(url, body)
}
\description{
Claude's token endpoint takes JSON (the generic [.token_request] form-encodes,
which Anthropic rejects), so this route needs its own POST. Reuses [.as_token].
}
\keyword{internal}
