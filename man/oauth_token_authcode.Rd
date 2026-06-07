% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_token_authcode}
\alias{oauth_token_authcode}
\title{Run the authorization-code flow end to end}
\usage{
oauth_token_authcode(client, scope = NULL, port = 1410L,
                     open_browser = interactive(), timeout = 120)
}
\arguments{
\item{client}{A [oauth_client] with an \code{auth_url}.}

\item{scope}{Optional space-delimited scope string.}

\item{port}{Loopback port for the listener; must match the port in
\code{client$redirect_uri} (default 1410).}

\item{open_browser}{Open the URL automatically (default: interactive only).}

\item{timeout}{Seconds to wait for the redirect.}
}
\value{
A \code{tinyoauth_token} (with a refresh token, when the provider
  issues one).
}
\description{
Prints (and optionally opens) the authorization URL, waits for the redirect
on a loopback listener, verifies \code{state}, and exchanges the code.
}
\examples{
\dontrun{
tok <- oauth_token_authcode(spotify, scope = "user-read-email")
}
}
