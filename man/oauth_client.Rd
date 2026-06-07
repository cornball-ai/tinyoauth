% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_client}
\alias{oauth_client}
\title{Define an OAuth 2.0 client}
\usage{
oauth_client(id, secret = NULL, token_url, auth_url = NULL,
             redirect_uri = "http://127.0.0.1:1410/")
}
\arguments{
\item{id}{Client (application) id.}

\item{secret}{Client secret, or NULL for public clients.}

\item{token_url}{The provider's token endpoint.}

\item{auth_url}{The provider's authorization endpoint (needed for the
authorization-code grant; omit for client-credentials only).}

\item{redirect_uri}{Redirect URI registered with the provider. Use a
loopback IP literal over http (\code{127.0.0.1}); many providers reject
\code{localhost}.}
}
\value{
A \code{tinyoauth_client} object.
}
\description{
Define an OAuth 2.0 client
}
\examples{
spotify <- oauth_client(
  id = "your_id", secret = "your_secret",
  token_url = "https://accounts.spotify.com/api/token",
  auth_url  = "https://accounts.spotify.com/authorize")
}
