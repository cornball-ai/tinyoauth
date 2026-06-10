% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_exchange_code}
\alias{oauth_exchange_code}
\title{Exchange an authorization code for a token}
\usage{
oauth_exchange_code(client, code)
}
\arguments{
\item{client}{A [oauth_client].}

\item{code}{The authorization code from the redirect.}
}
\value{
A \code{tinyoauth_token}.
}
\description{
Exchange an authorization code for a token
}
\examples{
\dontrun{
# `code` is the value the provider redirects back after the user approves.
tok <- oauth_exchange_code(client, code)
}
}
