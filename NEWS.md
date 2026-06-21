# tinyoauth 0.1.0.1

* New Anthropic Claude (Claude Code) login route: `anthropic_claude_client()`
  and `oauth_token_anthropic()`. An OAuth 2.0 authorization-code grant with
  client-generated PKCE (S256) against Anthropic's public Claude Code client,
  using the manual-paste flow (Claude's callback page displays the code).
  Verified end to end against a live Claude subscription. Adds `digest` to
  Imports for the S256 challenge.

# tinyoauth 0.1.0

* First CRAN release. Consolidates the 0.0.1.x development cycle: a minimal
  OAuth 2.0 client (client-credentials and authorization-code grants with
  token refresh), an `oauth_import_httr()` bridge for legacy `.httr-oauth`
  caches, a no-listener `manual` mode that auto-engages on remote/headless
  sessions, and an OpenAI Codex device-login helper. Contributions to the
  Codex route from Sounkou Mahamane Toure.

# tinyoauth 0.0.1.6

* `oauth_token_authcode()` now defaults `manual = NA`, which auto-detects a
  remote/headless session (SSH, RStudio Server, or unix with no display) and
  uses the manual paste flow instead of hanging on a loopback listener the
  redirect can never reach. A first-time login over SSH (e.g. through a
  pipeline that calls `tinytuber::yt_oauth()`) now shows the paste prompt
  rather than blocking. Pass `manual = TRUE`/`FALSE` to force either mode.

# tinyoauth 0.0.1.5

* `oauth_token_authcode()` now prints "Authorization complete." after a
  successful exchange (the manual mode previously finished silently).
* Clearer `manual = TRUE` instructions: the copy-the-address-bar step now
  includes the `Ctrl+L` / `Ctrl+C` (`Cmd` on macOS) shortcut, and a short
  reminder lives in the input prompt itself -- the line still on screen when
  you return from the browser.

# tinyoauth 0.0.1.4

* `oauth_token_authcode(manual = TRUE)` adds a no-listener mode for
  remote/headless use: it prints step-by-step instructions, you approve in a
  browser anywhere, then paste the redirected `127.0.0.1` address (or the bare
  code) back at the prompt. Uses the same registered loopback `redirect_uri`,
  so it is not the deprecated out-of-band flow. Flows through wrappers that pass
  `...` to it (e.g. `tinytuber::yt_oauth(..., manual = TRUE)`).

# tinyoauth 0.0.1.3

* Fixed a crash in `oauth_token_openai_codex()` device login when OpenAI's poll
  endpoint returns its `error` as a nested object (`{code, message}`) rather
  than a string — the classifier compared a length>1 value and errored on the
  first poll. The error field is now reduced to a single string before
  matching.

# tinyoauth 0.0.1.2

* `oauth_token_openai_codex()` device polling now keeps polling on HTTP
  403/404 (OpenAI's "still pending" responses) instead of erroring, while
  still stopping immediately on hard denials. It also finalizes the token on
  every path, so a valid cached token missing `account_id` has it derived from
  the access-token JWT; with `login = FALSE`, a token whose account id can't be
  determined returns `NULL`.

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
