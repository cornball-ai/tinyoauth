% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_token_client}
\alias{oauth_token_client}
\title{Fetch a token via the client-credentials grant}
\usage{
oauth_token_client(client)
}
\arguments{
\item{client}{A [oauth_client].}
}
\value{
A \code{tinyoauth_token}.
}
\description{
App-only access (no user context).
}
\examples{
\dontrun{
tok <- oauth_token_client(spotify)
}
}
