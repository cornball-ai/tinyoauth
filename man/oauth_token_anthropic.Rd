% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_token_anthropic}
\alias{oauth_token_anthropic}
\title{Get a valid Anthropic Claude token, using the cache and refreshing as needed}
\usage{
oauth_token_anthropic(cache = oauth_cache_path(anthropic_claude_client()),
                      open_url = interactive(), login = TRUE)
}
\arguments{
\item{cache}{Cache file path, or \code{NULL} to disable caching. Defaults to
[oauth_cache_path] for the Claude client.}

\item{open_url}{Open the authorization URL automatically (default: interactive
sessions only).}

\item{login}{Run the login flow when no usable cached/refreshable token exists
(default \code{TRUE}). Pass \code{FALSE} to get the cached (and
refreshed-if-needed) token or \code{NULL}, without ever prompting -- useful
inside a request path where an interactive login would be wrong.}
}
\value{
A \code{tinyoauth_token} with \code{access_token},
  \code{refresh_token}, and \code{expires_at}; or \code{NULL} when
  \code{login} is \code{FALSE} and no usable token is cached.
}
\description{
The Claude analogue of [oauth_token]: returns a cached token if still valid,
refreshes it if expired and a refresh token is available, otherwise runs the
manual-paste login flow. The token is written back to \code{cache}.
}
\details{
These are subscription credentials minted for Claude Code; using them is
subject to Anthropic's terms for that product.

}
\examples{
\dontrun{
tok <- oauth_token_anthropic()
curl::handle_setheaders(curl::new_handle(),
                        Authorization = oauth_bearer(tok),
                        "anthropic-beta" = "oauth-2025-04-20")
}
}
