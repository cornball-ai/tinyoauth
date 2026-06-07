% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_authorize_url}
\alias{oauth_authorize_url}
\title{Build an authorization URL}
\usage{
oauth_authorize_url(client, scope = NULL, state = NULL)
}
\arguments{
\item{client}{A [oauth_client] with an \code{auth_url}.}

\item{scope}{Optional space-delimited scope string.}

\item{state}{Optional opaque state for CSRF protection.}
}
\value{
The authorization URL to open in a browser.
}
\description{
Build an authorization URL
}
\examples{
oauth_authorize_url(
  oauth_client("id", token_url = "https://x/token",
               auth_url = "https://x/authorize"),
  scope = "user-read-email")
}
