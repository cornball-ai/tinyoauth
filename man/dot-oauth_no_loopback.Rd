% tinyrox says don't edit this manually, but it can't stop you!
\name{.oauth_no_loopback}
\alias{.oauth_no_loopback}
\title{Is this a session where a loopback OAuth listener cannot catch the redirect?}
\usage{
.oauth_no_loopback()
}
\description{
\code{TRUE} for SSH sessions, RStudio Server, and headless unix (no X or
Wayland display): in all of these the browser runs on a different machine, so
the redirect to a \code{127.0.0.1} listener never arrives and the listener
would hang. [oauth_token_authcode] uses this to default to the manual paste
flow. macOS desktops have no \code{DISPLAY} but a working browser, so they
are not treated as headless.
}
\keyword{internal}
