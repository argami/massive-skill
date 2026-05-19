# Massive Skill

Claude Code plugin and Agent Skill for the [Massive Web Render API](https://joinmassive.com). Fetch any URL, search Google, or query AI chatbots — with JavaScript rendering, CAPTCHA solving, and 195+ country geo-targeting.

## Installation

**Claude Code** (native plugin):
```bash
claude plugin install argami/massive-skill
```
When enabled, Claude Code prompts for your API token and stores it securely in the OS keychain.

**skills.sh** (30+ agents: Cursor, Codex, Copilot, Windsurf, Gemini CLI, etc.):
```bash
npx skills add argami/massive-skill
```
The agent will ask for your API token on first use. No manual env var setup needed.

Get a token at [partners.joinmassive.com](https://partners.joinmassive.com/).

## What It Does

| Endpoint | Use for |
|---|---|
| `/browser` | Fetch any URL as HTML, Markdown, or raw |
| `/search` | Google search results with AI overviews |
| `/ai` | ChatGPT, Gemini, Perplexity, Copilot completions |

All endpoints support geo-targeting (190+ countries), device emulation, async scheduling, and cache control.

## Quick Start

```shell
# Fetch a page as Markdown
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/browser?url=https://example.com/&format=markdown'

# Google search
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/search?terms=best+running+shoes'

# Ask ChatGPT
curl -H "Authorization: Bearer $MASSIVE_TOKEN" \
  'https://render.joinmassive.com/ai?prompt=best+coffee+shops&model=chatgpt'
```

## License

MIT
