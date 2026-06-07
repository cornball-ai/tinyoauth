# tinyoauth 0.0.1.1

* Added an OpenAI Codex (ChatGPT) device-login route: `oauth_token_openai_codex()`,
  `openai_codex_client()`, and `openai_codex_account_id()`. Tokens are cached and
  refreshed through the existing `oauth_cache_path()` / `oauth_refresh()`
  machinery. Adapted from Sounkou Mahamane Toure's llm.api PR #20, which proved
  the device flow; tinyoauth adds the token persistence and refresh.
* Added `oauth_jwt_payload()`, a generic (signature-free) decode of a JWT
  payload for reading claims from tokens you already trust.

# tinyoauth 0.0.1

* Initial release: a minimal OAuth 2.0 client (client-credentials and
  authorization-code grants with token refresh) built on curl and jsonlite.
