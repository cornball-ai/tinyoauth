% tinyrox says don't edit this manually, but it can't stop you!
\name{openai_codex_client}
\alias{openai_codex_client}
\title{OAuth client for the OpenAI Codex (ChatGPT) device-login flow}
\usage{
openai_codex_client()
}
\value{
A \code{tinyoauth_client} with extra \code{device_usercode_url},
  \code{device_token_url}, and \code{verification_uri} fields.
}
\description{
A preconfigured [oauth_client] for ChatGPT-subscription-backed Codex access,
carrying OpenAI's device-authorization endpoints alongside the standard token
endpoint. The client id is OpenAI's public native-app identifier, not a
secret.
}
\examples{
openai_codex_client()
}
