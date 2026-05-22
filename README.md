# Massive Skill

[![validate](https://github.com/argami/massive-skill/actions/workflows/validate.yml/badge.svg)](https://github.com/argami/massive-skill/actions/workflows/validate.yml)
[![version](https://img.shields.io/badge/version-0.1.0-blue)](.claude-plugin/plugin.json)
[![license](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Claude Code plugin and Agent Skill for the [Massive Web Render API](https://joinmassive.com). Fetch any URL, search Google, or query AI chatbots — with JavaScript rendering, CAPTCHA solving, and 195+ country geo-targeting.

## Installation

**Claude Code** (native plugin):
```bash
claude plugin marketplace add https://github.com/argami/massive-skill
claude plugin install massive
```
Claude Code prompts for your API token on first enable and stores it securely in the OS keychain.

**skills.sh** (30+ agents: Cursor, Codex, Copilot, Windsurf, Gemini CLI, etc.):
```bash
npx skills add argami/massive-skill
```
The agent asks for your API token on first use. No manual env var setup needed.

Get a token at [partners.joinmassive.com](https://partners.joinmassive.com/).

## What You Get

Once installed, your agent gains three capabilities:

| Capability | Example prompts | What happens |
|---|---|---|
| **Web Fetch** | "This page is blocked, can you get its content?" or "Fetch this JS-heavy site as markdown" | Fetches any URL through Massive's browser, handling CAPTCHAs, JS rendering, and geo-restrictions |
| **Google Search** | "Search Google for best running shoes" or "Get me localized search results for Paris" | Returns structured SERPs with AI overviews and "People also ask" |
| **AI Chat** | "What does ChatGPT say about X?" or "Ask Gemini about the latest AI trends" | Queries ChatGPT, Gemini, Perplexity, or Copilot with optional geo-targeting |

If another fetch or search tool returns blocked or incomplete content, the agent retries with Massive automatically.

## Repository Structure

```
.
├── .claude-plugin/
│   ├── marketplace.json     # Claude Code marketplace manifest
│   └── plugin.json          # Claude Code plugin manifest
├── .github/workflows/
│   └── validate.yml         # CI: structural + integration tests
├── skills/massive/
│   ├── SKILL.md             # Agent skill (decision tree, shared params, error handling)
│   └── references/
│       ├── browser.md       # /browser endpoint reference
│       ├── search.md        # /search endpoint reference
│       └── ai.md            # /ai endpoint reference
├── test/
│   ├── validate.sh          # 24 structural checks (shell)
│   └── install.bats         # 12 integration + E2E tests (bats)
├── .pre-commit-config.yaml
└── README.md
```

## Development

### Pre-commit hooks

Pre-commit runs both test suites on every commit. Install:

```bash
brew install pre-commit bats-core
pre-commit install
```

### Running tests locally

```bash
# Structural validation — 24 checks
bash test/validate.sh
```

Covers `plugin.json`, `marketplace.json`, `SKILL.md` frontmatter, directory structure, reference files, and link integrity.

```bash
# Integration + E2E tests — 12 checks
bats test/install.bats
```

| # | Test | What it verifies |
|---|---|---|
| 1–10 | Structural | JSON schemas, required fields, YAML frontmatter, reference files |
| 11 | **Claude Code E2E** | `marketplace add` → `install massive` → `list` (must show `massive`) → `uninstall` → `marketplace remove` |
| 12 | **skills.sh E2E** | `skills add <git-url> --global` → `list --global` (must show `massive-skill`) → `uninstall --global` |

Tests 11 and 12 validate the commands users actually run from the README — if either fails, the plugin or skill is not installable.

### CI

GitHub Actions runs both suites on every push and PR to `main`. The workflow installs `skills-cli` and `@anthropic-ai/claude-code` from npm so the E2E install tests run with real CLIs.

## License

MIT
