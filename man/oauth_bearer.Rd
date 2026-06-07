% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_bearer}
\alias{oauth_bearer}
\title{Authorization header value for a token}
\usage{
oauth_bearer(token)
}
\arguments{
\item{token}{A \code{tinyoauth_token} or a raw access-token string.}
}
\value{
A string like \code{"Bearer abc123"} for use as an HTTP
  \code{Authorization} header.
}
\description{
Authorization header value for a token
}
\examples{
\dontrun{
h <- curl::new_handle()
curl::handle_setheaders(h, Authorization = oauth_bearer(tok))
}
}
