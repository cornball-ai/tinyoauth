% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_request}
\alias{oauth_request}
\title{Make an authenticated request}
\usage{
oauth_request(token, url, method = "GET", query = NULL, body = NULL,
              headers = NULL, flatten = FALSE, retries = 3L)
}
\arguments{
\item{token}{A \code{tinyoauth_token}, a (legacy) httr token, or a raw
access-token string.}

\item{url}{Endpoint URL.}

\item{method}{HTTP method (default "GET").}

\item{query}{Optional named list of query parameters.}

\item{body}{Optional R object sent as a JSON body.}

\item{headers}{Optional named character vector of extra headers.}

\item{flatten}{Passed to \code{jsonlite::fromJSON} (default FALSE).}

\item{retries}{Attempts on transport errors / HTTP 5xx (default 3).}
}
\value{
Parsed JSON, or invisibly \code{NULL} for an empty response body.
  Non-2xx responses raise an error carrying the status and body.
}
\description{
Sends an HTTP request with the token as a Bearer header, retrying transient
failures, and parses a JSON response. A convenience over building a curl
handle by hand; for anything exotic, use [oauth_bearer] with curl directly.
}
\examples{
\dontrun{
oauth_request(tok, "https://api.spotify.com/v1/me")
}
}
