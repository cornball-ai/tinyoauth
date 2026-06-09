% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_token_authcode}
\alias{oauth_token_authcode}
\title{Run the authorization-code flow end to end}
\usage{
oauth_token_authcode(client, scope = NULL, port = 1410L,
                     open_browser = interactive(), timeout = 120, manual = NA)
}
\arguments{
\item{client}{A [oauth_client] with an \code{auth_url}.}

\item{scope}{Optional space-delimited scope string.}

\item{port}{Loopback port for the listener; must match the port in
\code{client$redirect_uri} (default 1410).}

\item{open_browser}{Open the URL automatically (default: interactive only).}

\item{timeout}{Seconds to wait for the redirect.}

\item{manual}{Skip the loopback listener and read the redirected address (or
bare code) from the console instead. The default (\code{NA}) auto-detects:
it switches to manual on a remote/headless session (SSH, RStudio Server, or
unix with no display), where the browser runs elsewhere and the redirect
can never reach a local listener (so the listener would just hang). Pass
\code{TRUE}/\code{FALSE} to force it. In manual mode the browser shows a
"can't reach 127.0.0.1" page after you approve -- that is expected; copy
its address bar and paste it.}
}
\value{
A \code{tinyoauth_token} (with a refresh token, when the provider
  issues one).
}
\description{
Prints (and optionally opens) the authorization URL, then obtains the
redirect either by catching it on a loopback listener (default) or, with
\code{manual = TRUE}, by having you paste the redirected URL back. After
verifying \code{state}, it exchanges the code.
}
\examples{
\dontrun{
tok <- oauth_token_authcode(spotify, scope = "user-read-email")
tok <- oauth_token_authcode(google, manual = TRUE)  # force manual paste
}
}
