% tinyrox says don't edit this manually, but it can't stop you!
\name{oauth_token_openai_codex}
\alias{oauth_token_openai_codex}
\title{Get a valid OpenAI Codex token, using the cache and refreshing as needed}
\usage{
oauth_token_openai_codex(cache = oauth_cache_path(openai_codex_client()),
                         open_url = interactive(), timeout = 600)
}
\arguments{
\item{cache}{Cache file path, or \code{NULL} to disable caching. Defaults to
[oauth_cache_path] for the Codex client.}

\item{open_url}{Open the verification URL automatically (default: interactive
sessions only).}

\item{timeout}{Seconds to wait for device authorization (default 600).}
}
\value{
A \code{tinyoauth_token} with \code{access_token}, \code{refresh_token},
  \code{expires_at}, and \code{account_id}.
}
\description{
The Codex analogue of [oauth_token]: returns a cached token if still valid,
refreshes it if expired and a refresh token is available, otherwise runs the
device-login flow. The token carries an extra \code{account_id} field (the
ChatGPT account id) and is written back to \code{cache}.
}
\examples{
\dontrun{
tok <- oauth_token_openai_codex()
curl::handle_setheaders(curl::new_handle(),
                        Authorization = oauth_bearer(tok),
                        "chatgpt-account-id" = tok$account_id)
}
}
