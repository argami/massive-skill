# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Claude Code plugin + Agent Skill that gives AI agents access to the [Massive Web Render API](https://joinmassive.com) — fetch any URL (with JS rendering, CAPTCHA solving, 195+ country geo-targeting), search Google, or query AI chatbots (ChatGPT, Gemini, Perplexity, Copilot).

Users install this two ways:
- **Claude Code native plugin**: `claude plugin marketplace add <url>` + `claude plugin install massive`
- **Agent Skill (skills.sh)**: `npx skills add argami/massive-skill` — works with 30+ agents (Cursor, Codex, Copilot, Windsurf, etc.)

Both are backed by the same `skills/massive/SKILL.md` and reference files.

## Architecture

```
.claude-plugin/
├── plugin.json          # Claude Code plugin manifest — defines MCP server tools + userConfig
└── marketplace.json     # Marketplace manifest — wraps plugin.json for `claude plugin marketplace add`
skills/massive/
├── SKILL.md             # Agent skill with decision tree, shared params, error handling
└── references/
    ├── browser.md       # /browser endpoint reference (URL fetching)
    ├── search.md        # /search endpoint reference (Google SERPs)
    └── ai.md            # /ai endpoint reference (chatbot completions)
test/
├── validate.sh          # 24 structural checks (bash)
└── install.bats         # 12 integration + E2E tests (bats)
```

**Key design decisions:**

- `plugin.json` and `SKILL.md` are co-located so the same skill content works for both Claude Code and skills.sh install paths. The MCP tools defined in `plugin.json` (web_fetch, web_search, ai_chat_completion, account_status) mirror the three Massive API endpoints.
- The `skills/massive/` directory is auto-discovered by Claude Code for the native plugin path — no separate skill copy needed.
- All three Massive endpoints share auth (Bearer token), geotargeting params (country/subdivision/city), and async/sync scheduling — documented once in SKILL.md, with endpoint-specific params in the reference files.
- The API token is not bundled. For Claude Code, it's stored in the OS keychain via `userConfig.sensitive`. For skills.sh, the skill prompts on first use.

## Commands

```bash
# Structural validation — 24 checks (JSON schemas, YAML frontmatter, references, links)
bash test/validate.sh

# Integration + E2E tests — 12 checks (requires claude CLI + skills-cli installed)
bats test/install.bats

# Run both (pre-commit does this automatically)
bash test/validate.sh && bats test/install.bats

# Install pre-commit hooks
brew install pre-commit bats-core
pre-commit install
```

**Pre-commit** runs both test suites on matching file changes. CI (`.github/workflows/validate.yml`) runs them on push/PR to `main`.

## What changes where

| What you're doing | Files to touch |
|---|---|
| Add a new Massive API capability | Add reference file in `references/`, update SKILL.md decision tree, add MCP tool in `plugin.json` |
| Fix docs or error handling | `SKILL.md` or the specific `references/*.md` |
| Add structural checks | `test/validate.sh` |
| Add E2E install tests | `test/install.bats` |
| Change install metadata | `plugin.json` (plugin) or `marketplace.json` (marketplace listing) |

## Versioning

Single source of truth: `plugin.json` version field. The marketplace and skill should track it. There's no build step — everything is configuration files consumed directly by Claude Code or skills.sh.

<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `rtk`**. If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `rtk`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct
rtk git add . && rtk git commit -m "msg" && rtk git push
```

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
rtk cargo build         # Cargo build output
rtk cargo check         # Cargo check output
rtk cargo clippy        # Clippy warnings grouped by file (80%)
rtk tsc                 # TypeScript errors grouped by file/code (83%)
rtk lint                # ESLint/Biome violations grouped (84%)
rtk prettier --check    # Files needing format only (70%)
rtk next build          # Next.js build with route metrics (87%)
```

### Test (90-99% savings)
```bash
rtk cargo test          # Cargo test failures only (90%)
rtk vitest run          # Vitest failures only (99.5%)
rtk playwright test     # Playwright failures only (94%)
rtk test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
rtk git status          # Compact status
rtk git log             # Compact log (works with all git flags)
rtk git diff            # Compact diff (80%)
rtk git show            # Compact show (80%)
rtk git add             # Ultra-compact confirmations (59%)
rtk git commit          # Ultra-compact confirmations (59%)
rtk git push            # Ultra-compact confirmations
rtk git pull            # Ultra-compact confirmations
rtk git branch          # Compact branch list
rtk git fetch           # Compact fetch
rtk git stash           # Compact stash
rtk git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
rtk gh pr view <num>    # Compact PR view (87%)
rtk gh pr checks        # Compact PR checks (79%)
rtk gh run list         # Compact workflow runs (82%)
rtk gh issue list       # Compact issue list (80%)
rtk gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
rtk pnpm list           # Compact dependency tree (70%)
rtk pnpm outdated       # Compact outdated packages (80%)
rtk pnpm install        # Compact install output (90%)
rtk npm run <script>    # Compact npm script output
rtk npx <cmd>           # Compact npx command output
rtk prisma              # Prisma without ASCII art (88%)
```

### Files & Search (60-75% savings)
```bash
rtk ls <path>           # Tree format, compact (65%)
rtk read <file>         # Code reading with filtering (60%)
rtk grep <pattern>      # Search grouped by file (75%)
rtk find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
rtk err <cmd>           # Filter errors only from any command
rtk log <file>          # Deduplicated logs with counts
rtk json <file>         # JSON structure without values
rtk deps                # Dependency overview
rtk env                 # Environment variables compact
rtk summary <cmd>       # Smart summary of command output
rtk diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
rtk docker ps           # Compact container list
rtk docker images       # Compact image list
rtk docker logs <c>     # Deduplicated logs
rtk kubectl get         # Compact resource list
rtk kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
rtk curl <url>          # Compact HTTP responses (70%)
rtk wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
rtk gain                # View token savings statistics
rtk gain --history      # View command history with savings
rtk discover            # Analyze Claude Code sessions for missed RTK usage
rtk proxy <cmd>         # Run command without filtering (for debugging)
rtk init                # Add RTK instructions to CLAUDE.md
rtk init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->
