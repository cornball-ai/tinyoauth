% tinyrox says don't edit this manually, but it can't stop you!
\name{.listen_for_redirect}
\alias{.listen_for_redirect}
\title{Catch a single OAuth redirect on a loopback port}
\usage{
.listen_for_redirect(port = 1410L, timeout = 120)
}
\arguments{
\item{port}{Loopback port to listen on (must match the redirect URI).}

\item{timeout}{Seconds to wait for the redirect.}
}
\value{
Named list of query parameters from the redirect.
}
\description{
Opens a one-shot \code{serverSocket()} listener, accepts the browser
redirect, replies with a small page, and returns the parsed query.
}
\keyword{internal}
