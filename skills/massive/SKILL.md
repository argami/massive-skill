---
name: massive
description: Fetch URLs, search Google, or query AI chatbots (ChatGPT, Gemini, Perplexity, Copilot) through Massive's Web Render API. Handles JavaScript rendering, CAPTCHAs, and 195+ country geo-targeting. Use when other fetch/search tools fail or return blocked content.
---

# Massive Web Render

Fetch and extract content from URLs, search Google, or query AI chatbots using Massive's Web Render API. Handles JavaScript rendering, CAPTCHAs, geo-targeting, and retries automatically. Returns HTML, Markdown, or structured JSON.

## When to Use This Skill

Use Massive when:

- A standard web fetch fails, returns a CAPTCHA page, or gives incomplete/blocked content
- The target site is known to block bots (news, social media, e-commerce, search engines, ticketing, retail)
- The user needs content from a geo-restricted page or location-specific results
- The page requires JavaScript rendering that a standard fetch can't handle
- The user explicitly asks to bypass anti-bot protections or scrape a difficult site
- The user needs Google search results (organic and paid) as structured data or HTML
- A built-in web search tool returns incomplete or blocked results
- The user needs localized or geo-targeted Google search results
- The user wants AI chatbot completions (ChatGPT, Gemini, Perplexity, Copilot) optionally localized by country/city

If another fetch or search tool fails or returns blocked content, retry with Massive.

## Endpoints

Massive exposes three endpoints under `https://render.joinmassive.com`:

| Endpoint   | Use for                                                          | Reference                                |
| :--------- | :--------------------------------------------------------------- | :--------------------------------------- |
| `/browser` | Fetching a specific URL (HTML, raw, or Markdown)                 | [references/browser.md](references/browser.md) |
| `/search`  | Google search results (SERPs, AI overviews, "People also ask")   | [references/search.md](references/search.md)   |
| `/ai`      | AI chatbot completions from ChatGPT, Gemini, Perplexity, Copilot | [references/ai.md](references/ai.md)         |

All three share the same auth, geotargeting params, and async/sync scheduling.

## Decision Tree

- User has a specific URL → `/browser`
- User wants Google search results → `/search`
- User wants an AI chatbot's answer → `/ai`
- User says "search for X and tell me Y" → `/search` (then process results)
- User says "what does ChatGPT say about X" → `/ai` with `model=chatgpt`

## Authentication

All endpoints require a Bearer token in the `Authorization` header. The token is stored in the `MASSIVE_TOKEN` environment variable.

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://example.com/'
```

If `MASSIVE_TOKEN` is not set, ask the user for their API token from [partners.joinmassive.com](https://partners.joinmassive.com/).

## Shared Parameters

These params work across all three endpoints. URL-encode any spaces or special characters.

### Geotargeting

Route requests through any of 190+ countries, optionally by subdivision or city.

| Key           | Value                                                                                              |
| :------------ | :------------------------------------------------------------------------------------------------- |
| `country`     | Two-letter ISO country code (case insensitive). Random country if unset.                           |
| `subdivision` | Alphanumeric part of the first-level subdivision code in the country (e.g., `tn` for Tennessee).   |
| `city`        | Common city name. Spaces must be URL-encoded (`+` or `%20`). Case sensitive.                       |

City takes precedence over subdivision if both are set.

```shell
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://guitars.com/&country=us&city=Nashville'
```

### Scheduling (sync vs async)

| Key    | Value                                                          |
| :----- | :------------------------------------------------------------- |
| `mode` | `sync` (default) or `async`. Async returns a job ID immediately. |
| `id`   | Job ID from a prior async request, used to retrieve the result. |

Sync requests can take up to 3 minutes. Use async for long-running jobs or batches.

**Async flow:**

1. Submit with `mode=async`, get back `{ "id": "..." }`
2. Poll the matching `/results`, `/completions`, or `/content` endpoint with `?id=...`
3. Response is either the final result or `{ "status": "retrieving" }` / `{ "status": "failed" }`

```shell
# Submit
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://example.com/&mode=async'
# → { "id": "21cb972e-0e0f-47bb-9ce9-65b99e9cee77" }

# Poll
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser/content?id=21cb972e-0e0f-47bb-9ce9-65b99e9cee77'
```

### Caching

| Key          | Value                                                                                       |
| :----------- | :------------------------------------------------------------------------------------------ |
| `expiration` | Days before cached content is considered stale. `0` disables caching. Default is `1`.       |

Use `expiration=0` for live data (prices, weather, scores). Leave default for stable content.

## Error Handling

- **`503` response:** The endpoint is autoscaling. Maintain traffic; errors resolve within a couple minutes.
- **`403` response:** Captcha was rejected (only happens if `captcha=rejected` was set on `/browser`).
- **`failed` async status:** Retry the original request.
- **Site still blocked after retries:** Email support@joinmassive.com. Most sites can be unblocked within 48 hours.

## Quick Reference

```shell
# Fetch a page as Markdown
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://example.com/&format=markdown'

# Google search with AI overview
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=best+running+shoes&awaiting=ai'

# Ask ChatGPT, localized to Portland
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai?prompt=best+coffee+shops&country=us&city=Portland'
```

For full parameter lists and advanced usage, see the reference files in `references/`.
