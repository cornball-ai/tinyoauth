## Submission

This is a new submission.

tinyoauth is a dependency-light OAuth 2.0 client (curl + jsonlite) for the
client-credentials and authorization-code grants with token refresh, plus a
helper for the OpenAI Codex device-login flow.

## Test environments

* local: Ubuntu 24.04, R 4.6.x
* GitHub Actions: ubuntu-latest and macos-latest, R release
* win-builder: R-devel and R-release (via check_win_devel())

## R CMD check results

0 errors | 0 warnings | 1 note

The note is the standard "New submission" maintainer note.

## Notes for the reviewer

* Examples for functions that require a live OAuth provider, browser, or user
  credentials (`oauth_token()`, `oauth_token_authcode()`, `oauth_exchange_code()`,
  `oauth_refresh()`, `oauth_request()`, `oauth_token_client()`,
  `oauth_token_openai_codex()`, `oauth_import_httr()`) are wrapped in
  `\dontrun{}` because they cannot execute without authenticating against a real
  endpoint. The remaining exports (`oauth_client()`, `oauth_authorize_url()`,
  `oauth_bearer()`, `oauth_jwt_payload()`, `oauth_cache_path()`,
  `oauth_expired()`, `openai_codex_client()`, `openai_codex_account_id()`) have
  runnable examples.
* The token cache is written under `tools::R_user_dir("tinyoauth", "cache")`
  only; nothing is written to the user's home filespace. Tests redirect the
  `R_USER_*_DIR` roots to the session temp area.
