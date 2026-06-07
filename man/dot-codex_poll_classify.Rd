% tinyrox says don't edit this manually, but it can't stop you!
\name{.codex_poll_classify}
\alias{.codex_poll_classify}
\title{Classify a device-token poll response}
\usage{
.codex_poll_classify(status, body)
}
\description{
Returns one of \code{"ok"} (authorization granted), \code{"pending"} (keep
waiting), \code{"slow_down"} (back off), or \code{"error"} (give up).
}
\keyword{internal}
