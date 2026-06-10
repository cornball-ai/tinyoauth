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
\examples{
# A token whose access-token JWT carries the account-id claim:
claim <- jsonlite::toJSON(
  list("https://api.openai.com/auth" = list(chatgpt_account_id = "acct_123")),
  auto_unbox = TRUE)
b64url <- function(s) {
  chartr("+/", "-_", gsub("[\n=]", "", jsonlite::base64_enc(charToRaw(s))))
}
jwt <- paste("header", b64url(claim), "signature", sep = ".")
openai_codex_account_id(jwt)
}
