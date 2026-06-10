% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_expired}
\alias{oauth_expired}
\title{Is a token expired?}
\usage{
oauth_expired(token, leeway = 60)
}
\arguments{
\item{token}{A \code{tinyoauth_token}.}

\item{leeway}{Seconds of slack before the hard expiry (default 60).}
}
\value{
\code{TRUE} if expired (or within \code{leeway} of it); \code{FALSE}
  when there is no expiry recorded.
}
\description{
Is a token expired?
}
\examples{
expired <- structure(list(expires_at = Sys.time() - 1),
                     class = "tinyoauth_token")
oauth_expired(expired)
fresh <- structure(list(expires_at = Sys.time() + 3600),
                   class = "tinyoauth_token")
oauth_expired(fresh)
}
