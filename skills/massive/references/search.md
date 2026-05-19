# `/search` — Google Search Results

Extract organic and paid search results from Google as rendered HTML.

**Endpoint:** `GET https://render.joinmassive.com/search`

Live searches typically take a few seconds. Up to 3 minutes is allotted per call to allow for retries.

## Parameters

| Key          | Required | Value                                                                                                                                                              |
| :----------- | :------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `terms`      | ✅       | Query string, up to 255 characters. URL-encode spaces (`+` or `%20`). Use quotes for exact phrases: `"foo bar"`.                                                   |
| `serps`      | ⬜       | Number of result pages to retrieve, `1` to `10`. Default `1`.                                                                                                      |
| `size`       | ⬜       | Results per page, `0` to `100`. Unset by default.                                                                                                                  |
| `offset`     | ⬜       | Initial results to skip, `0` to `100`. No offset by default.                                                                                                       |
| `uule`       | ⬜       | Google's encoded location string for emulating search-from location. Actual location used if available.                                                            |
| `language`   | ⬜       | Language to search in. Common name, ISO code, or Google code (case insensitive).                                                                                   |
| `display`    | ⬜       | Display language for the search interface. Defaults to `language` if set.                                                                                          |
| `awaiting`   | ⬜       | Lazy results to wait for: `ai` (AI overview) or `answers` ("People also ask"). Repeat key for multiple. AI overviews are awaited up to 1 minute.                    |
| `expiration` | ⬜       | Days before cached results expire. `0` disables caching. Default `1`.                                                                                              |

Plus all [shared params](../SKILL.md#shared-parameters): `country`, `subdivision`, `city`, `mode`, `id`.

## Response Format

Search results are returned as rendered HTML. If you request multiple pages without infinite scrolling, each page's HTML is separated by an empty line (`\n\n`).

## Examples

### Basic search

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=foo+bar+baz'
```

### Exact phrase

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=%22best+running+shoes%22'
```

### Localized search

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=musical+instruments&country=us&subdivision=tn'
```

### AI overview and "People also ask"

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=how+tall+is+mount+everest&awaiting=ai&awaiting=answers'
```

### Pagination — get results 21-120

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=vpn+comparison&size=100&offset=20'
```

### Multiple pages

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=privacy+tools&serps=3'
```

### Async search

```shell
# Submit
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=prolonged+fasting&mode=async'
# → { "id": "078fd246-f0f7-44a0-aabb-cadd7b12454f" }

# Poll
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search/results?id=078fd246-f0f7-44a0-aabb-cadd7b12454f'
```

### Python example

```python
import os
import requests

resp = requests.get(
    "https://render.joinmassive.com/search",
    headers={"Authorization": f"Bearer {os.environ['MASSIVE_TOKEN']}"},
    params={
        "terms": "best laptops 2026",
        "country": "us",
        "awaiting": ["ai", "answers"],
    },
    timeout=180,
)
resp.raise_for_status()
html = resp.text
```

### Parsing results

Massive returns rendered HTML. Use a parser like BeautifulSoup or Cheerio to extract the parts you need (organic results, ads, AI overview, "People also ask"). The HTML structure mirrors Google's live SERP, so existing Google SERP parsers work.

```python
from bs4 import BeautifulSoup

soup = BeautifulSoup(html, "html.parser")
for result in soup.select("div.g"):
    title = result.select_one("h3")
    link = result.select_one("a")
    if title and link:
        print(title.text, link["href"])
```
