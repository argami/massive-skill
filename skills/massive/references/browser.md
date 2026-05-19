# `/browser` — Fetch URLs

Fetch any URL through Massive. Handles JavaScript rendering, captchas, retries, and bot detection.

**Endpoint:** `GET https://render.joinmassive.com/browser`

Up to 3 minutes is allotted per real-time call to accommodate captcha-solving and retries.

## Parameters

| Key          | Required | Premium | Value                                                                                                                  |
| :----------- | :------- | :------ | :--------------------------------------------------------------------------------------------------------------------- |
| `url`        | ✅       | ⬜      | URL of the page to fetch. URL-encode unsafe characters.                                                                |
| `difficulty` | ⬜       | ✅      | `low` (default), `medium`, or `high`. Higher difficulty pools are harder to detect.                                    |
| `speed`      | ⬜       | ✅      | `light` (default), `ridiculous` (~30% faster), or `ludicrous`.                                                         |
| `device`     | ⬜       | ⬜      | Device name to emulate. Get list from `/browser/devices`. Case insensitive, URL-encode spaces.                         |
| `captcha`    | ⬜       | ⬜      | `solved` (default), `ignored`, or `rejected`. `rejected` returns a `403` if a captcha is detected.                     |
| `readiness`  | ⬜       | ⬜      | `load` (default) or `domcontentloaded`. The browser event to await before snapshotting.                                |
| `delay`      | ⬜       | ⬜      | Extra seconds to wait before snapshotting, from `0.1` to `10`. No delay by default.                                    |
| `format`     | ⬜       | ⬜      | `rendered` (default), `raw`, or `markdown`.                                                                            |
| `expiration` | ⬜       | ⬜      | Days before cached content expires. `0` disables caching. Default `1`.                                                 |

Plus all [shared params](../SKILL.md#shared-parameters): `country`, `subdivision`, `city`, `mode`, `id`.

## Response Formats

- **`rendered`** (default): HTML after JavaScript execution
- **`raw`**: HTML as the server originally sent it, no rendering
- **`markdown`**: Cleaned Markdown optimized for LLM input

## Sticky Sessions

Reuse the same egress IP across requests by setting a `session` cookie. Sessions persist for up to 12 minutes.

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  -H 'Cookie: session=12345' \
  'https://render.joinmassive.com/browser?url=https://www.amazon.com/s?k=luggage'
```

Session value can be any unique identifier up to 255 characters. Use the same value across requests that should share a session.

## Examples

### Basic fetch

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://example.com/'
```

### Markdown for LLM consumption

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://en.wikipedia.org/wiki/Web_scraping&format=markdown'
```

### Mobile device emulation

```shell
# List devices first
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser/devices'

# Then fetch as that device
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://crackberry.com/&device=blackberry+playbook'
```

### Geo-targeted fetch

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://www.google.com/&country=jp&city=Tokyo'
```

### Cachebusting (live data)

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://api.weather.gov/alerts&expiration=0'
```

### JavaScript-heavy site with delay

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://app.example.com/&delay=3&readiness=load'
```

### Async fetch

```shell
# Submit
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://example.com/&mode=async'
# → { "id": "21cb972e-0e0f-47bb-9ce9-65b99e9cee77" }

# Poll
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser/content?id=21cb972e-0e0f-47bb-9ce9-65b99e9cee77'
```

### Python example

```python
import os
import requests

resp = requests.get(
    "https://render.joinmassive.com/browser",
    headers={"Authorization": f"Bearer {os.environ['MASSIVE_TOKEN']}"},
    params={
        "url": "https://example.com/",
        "format": "markdown",
        "country": "us",
    },
    timeout=180,
)
resp.raise_for_status()
print(resp.text)
```

### Node.js example

```javascript
const resp = await fetch(
  "https://render.joinmassive.com/browser?" + new URLSearchParams({
    url: "https://example.com/",
    format: "markdown",
    country: "us",
  }),
  { headers: { Authorization: `Bearer ${process.env.MASSIVE_TOKEN}` } }
);
const html = await resp.text();
```
