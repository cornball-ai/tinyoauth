## Submission

This is an update to the CRAN release 0.1.0. It adds one feature: an
Anthropic Claude (Claude Code) OAuth login route (`anthropic_claude_client()`
and `oauth_token_anthropic()`). The change is backwards-compatible -- two new
exported functions, no changes to existing behaviour. `digest` is added to
Imports for the PKCE (S256) challenge.

## Test environments

* local: Ubuntu 24.04, R 4.6.0
* win-builder: R-devel and R-release (via check_win_devel())

## R CMD check results

0 errors | 0 warnings | 1 note

The note is the standard CRAN-incoming "Days since last update" -- this update
follows 0.1.0 closely on purpose, to unblock a downstream package ('llm.api')
that needs the new `oauth_token_anthropic()` export before its own release.

## Notes for the reviewer

* Examples for functions that require a live OAuth provider, browser, or user
  credentials (`oauth_token()`, `oauth_token_authcode()`, `oauth_exchange_code()`,
  `oauth_refresh()`, `oauth_request()`, `oauth_token_client()`,
  `oauth_token_openai_codex()`, `oauth_token_anthropic()`, `oauth_import_httr()`)
  are wrapped in `\dontrun{}` because they cannot execute without authenticating
  against a real endpoint. The remaining exports (`oauth_client()`,
  `oauth_authorize_url()`, `oauth_bearer()`, `oauth_jwt_payload()`,
  `oauth_cache_path()`, `oauth_expired()`, `anthropic_claude_client()`,
  `openai_codex_client()`, `openai_codex_account_id()`) have runnable examples.
* The token cache is written under `tools::R_user_dir("tinyoauth", "cache")`
  only; nothing is written to the user's home filespace. Tests redirect the
  `R_USER_*_DIR` roots to the session temp area.
