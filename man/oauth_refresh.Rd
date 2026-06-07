% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_refresh}
\alias{oauth_refresh}
\title{Refresh an access token}
\usage{
oauth_refresh(client, token)
}
\arguments{
\item{client}{A [oauth_client].}

\item{token}{A \code{tinyoauth_token} carrying a refresh token.}
}
\value{
A refreshed \code{tinyoauth_token}. Providers that omit a new refresh
  token on refresh keep the existing one.
}
\description{
Refresh an access token
}
\examples{
\dontrun{
tok <- oauth_refresh(spotify, tok)
}
}
