# tinyoauth

Minimal OAuth 2.0 for R: the **client-credentials** and **authorization-code**
grants, with token **refresh** and on-disk caching. Built on
[`curl`](https://cran.r-project.org/package=curl) and
[`jsonlite`](https://cran.r-project.org/package=jsonlite) plus base R's
`serverSocket()` for the redirect listener. No `httr`/`httr2`.

## Why

The OAuth 2.0 token endpoints are just HTTP POSTs, and base R can listen for the
redirect on a loopback socket — so the whole dance needs no heavy HTTP stack.
`tinyoauth` carries two Imports (`curl`, `jsonlite`); `httr` pulls ~9 and `httr2`
more still.

## Install

```r
remotes::install_github("cornball-ai/tinyoauth")
```

## Use

```r
library(tinyoauth)

client <- oauth_client(
  id        = Sys.getenv("SPOTIFY_CLIENT_ID"),
  secret    = Sys.getenv("SPOTIFY_CLIENT_SECRET"),
  token_url = "https://accounts.spotify.com/api/token",
  auth_url  = "https://accounts.spotify.com/authorize"
)

# App-only (client credentials):
tok <- oauth_token_client(client)

# User context (opens a browser, caches + auto-refreshes):
tok <- oauth_token(client, scope = "user-read-email")

# Use it on a request:
h <- curl::new_handle()
curl::handle_setheaders(h, Authorization = oauth_bearer(tok))
curl::curl_fetch_memory("https://api.spotify.com/v1/me", handle = h)
```

The redirect listener binds the **server's** loopback (`127.0.0.1:<port>`), so on
a remote box either browse on that box, forward the port
(`ssh -L 1410:127.0.0.1:1410`), or paste the redirected URL back manually.

## License

MIT, © cornball.ai.
