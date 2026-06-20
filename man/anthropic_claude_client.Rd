% tinyrox says don't edit this manually, but it can't stop you!
\name{anthropic_claude_client}
\alias{anthropic_claude_client}
\title{OAuth client for the Anthropic Claude (Claude Code) login flow}
\usage{
anthropic_claude_client()
}
\value{
A \code{tinyoauth_client} with an extra \code{scope} field.
}
\description{
A preconfigured [oauth_client] for Claude-subscription-backed access, carrying
Anthropic's authorize and token endpoints plus the Claude Code scope string.
The client id is Anthropic's public Claude Code identifier, not a secret.
}
\examples{
anthropic_claude_client()
}
