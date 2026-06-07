% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_import_httr}
\alias{oauth_import_httr}
\title{Import an httr `.httr-oauth` cache into tinyoauth}
\usage{
oauth_import_httr(path = ".httr-oauth", which = 1L)
}
\arguments{
\item{path}{Path to the httr cache (default \code{".httr-oauth"}).}

\item{which}{Which cached token to import when the file holds several
(1-based; default 1).}
}
\value{
A list with \code{client} (a [oauth_client]) and \code{token} (a
  \code{tinyoauth_token}).
}
\description{
Reads a token cached by \pkg{httr}'s \code{oauth2.0_token()} and returns a
tinyoauth client and token built from it -- the app credentials, endpoints,
and (crucially) the refresh token. This lets a package migrating off
\pkg{httr} reuse an existing authorization instead of forcing users to log in
again.
}
\details{
The imported access token is marked expired, since httr's cached access token
is usually stale: the durable credential is the refresh token. Pass the result
to [oauth_refresh] or [oauth_token] to mint a fresh access token.

}
\examples{
\dontrun{
imported <- oauth_import_httr("~/project/.httr-oauth")
token <- oauth_refresh(imported$client, imported$token)
}
}
