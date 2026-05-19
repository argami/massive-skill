# `/ai` — AI Chatbot Completions

Get completions and grounding sources from frontier AI chatbots (ChatGPT, Gemini, Perplexity, Copilot) as structured JSON or raw HTML.

**Endpoint:** `GET https://render.joinmassive.com/ai`

Live conversations average several seconds. Up to 3 minutes is allotted per call.

## Parameters

| Key          | Required | Value                                                                                                                |
| :----------- | :------- | :------------------------------------------------------------------------------------------------------------------- |
| `prompt`     | ✅       | The question or instruction, up to 2,047 characters. URL-encode spaces (`+` or `%20`).                               |
| `model`      | ⬜       | `chatgpt` (default), `gemini`, `perplexity`, or `copilot`.                                                            |
| `device`     | ⬜       | Device name to emulate. Get list from `/ai/devices`. Case insensitive, URL-encode spaces.                            |
| `format`     | ⬜       | `json` (default), `rendered`, or `raw`.                                                                              |
| `expiration` | ⬜       | Days before cached completion expires. `0` disables caching. Default `1`.                                            |

Plus all [shared params](../SKILL.md#shared-parameters): `country`, `subdivision`, `city`, `mode`, `id`.

## Response Format

### `json` (default)

Returns a structured object:

| Key          | Value                                                                          |
| :----------- | :----------------------------------------------------------------------------- |
| `model`      | The AI model that generated the completion                                     |
| `query`      | The user prompt the completion was generated for                               |
| `html`       | Rendered HTML of the entire conversation                                       |
| `prompt`     | Rendered HTML of just the prompt portion                                       |
| `completion` | Rendered HTML of just the completion portion                                   |
| `sources`    | Rendered HTML of just the sources portion                                      |
| `subqueries` | Array of fanout queries the model searched (only some models expose these)    |
| `device`     | The emulated device name (if any)                                              |
| `country`    | The ISO code of the country browsed from                                       |
| `subdivision`| The partial ISO code of the subdivision                                        |
| `city`       | The common name of the city                                                    |

### `rendered`

Full HTML of the conversation after JavaScript execution.

### `raw`

Unrendered HTML as the chatbot originally sent it.

## Examples

### Basic completion

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai?prompt=best+basketball+shoes+for+2026'
```

### Specific model with location

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai?prompt=best+coffee+shops&model=perplexity&country=us&city=Portland'
```

### Mobile device emulation

```shell
# List devices
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai/devices'

# Use a device
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai?prompt=what+happened+to+blackberry&device=blackberry+playbook'
```

### Async completion

```shell
# Submit
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai?prompt=prolonged+fasting&mode=async'
# → { "id": "1851dab8-4619-409f-893f-47dd3a180bc3" }

# Poll
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai/completions?id=1851dab8-4619-409f-893f-47dd3a180bc3'
```

### Live data (no cache)

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai?prompt=current+weather&expiration=0'
```

### Python example

```python
import os
import requests

resp = requests.get(
    "https://render.joinmassive.com/ai",
    headers={"Authorization": f"Bearer {os.environ['MASSIVE_TOKEN']}"},
    params={
        "prompt": "find vintage guitar stores",
        "model": "chatgpt",
        "country": "us",
        "subdivision": "tn",
    },
    timeout=180,
)
resp.raise_for_status()
data = resp.json()

print(data["completion"])  # HTML of just the answer
print(data["sources"])     # HTML of cited sources
```

### Use Cases

- **Generative engine optimization (GEO):** Track how your brand appears in AI answers across regions
- **Competitive intelligence:** Monitor how chatbots describe competitors
- **Localized AI research:** Get how ChatGPT answers a query when run from Tokyo vs. New York
- **Sources extraction:** Pull the citation list from Perplexity or Copilot for a query
