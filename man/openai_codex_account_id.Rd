% tinyrox says don't edit this manually, but it can't stop you!
\name{openai_codex_account_id}
\alias{openai_codex_account_id}
\title{Extract the ChatGPT account id from a Codex token}
\usage{
openai_codex_account_id(token)
}
\arguments{
\item{token}{A \code{tinyoauth_token} (or raw access-token string).}
}
\value{
The account id string, or \code{NULL} if absent.
}
\description{
Reads the \code{chatgpt_account_id} claim that OpenAI nests under
\code{https://api.openai.com/auth} in the access-token JWT.
}
