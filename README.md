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

## Development

### Pre-commit hooks

Pre-commit runs `validate.sh` and `bats` tests on every commit. Install:

```bash
brew install pre-commit bats-core
pre-commit install
```

### Running tests locally

```bash
# Structural validation (21 checks)
bash test/validate.sh

# Bats integration tests (11 checks)
bats test/install.bats
```

Tests validate:
- `plugin.json` structure, required fields, and sensitive token config
- `SKILL.md` YAML frontmatter and reference link integrity
- Directory structure and reference files (browser, search, ai)
- `claude plugin validate` and `skills` CLI availability

### CI

GitHub Actions runs the full suite on every push and PR to `main`.

## License

MIT
