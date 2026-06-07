% tinyrox says don't edit this manually, but it can't stop you!
\name{.codex_device_poll}
\alias{.codex_device_poll}
\title{Poll the device-token endpoint until the user authorizes (or we time out)}
\usage{
.codex_device_poll(client, device, timeout = 600, sleep = Sys.sleep,
                   post = .codex_post_json)
}
\arguments{
\item{sleep}{Sleep function, injectable for testing.}

\item{post}{JSON-POST function, injectable for testing.}
}
\description{
Poll the device-token endpoint until the user authorizes (or we time out)
}
\keyword{internal}
