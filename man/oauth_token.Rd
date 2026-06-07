% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_token}
\alias{oauth_token}
\title{Get a valid token, using the cache and refreshing as needed}
\usage{
oauth_token(client, scope = NULL, cache = oauth_cache_path(client), ...)
}
\arguments{
\item{client}{A [oauth_client].}

\item{scope}{Optional space-delimited scope string (for first authorization).}

\item{cache}{Cache file path, or \code{NULL} to disable caching. Defaults to
[oauth_cache_path].}

\item{...}{Passed to [oauth_token_authcode] (e.g. \code{port},
\code{open_browser}).}
}
\value{
A valid \code{tinyoauth_token}.
}
\description{
Returns a cached token if still valid; refreshes it if expired and a refresh
token is available; otherwise runs the authorization-code flow. The result is
written back to \code{cache}.
}
\examples{
\dontrun{
tok <- oauth_token(spotify, scope = "user-read-email")
}
}
