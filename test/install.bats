#!/usr/bin/env bats

ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  cd "$ROOT"
}

# ── Helper: skip if CLI not found ──────────────────────────────

skip_if_missing() {
  if ! command -v "$1" &>/dev/null; then
    skip "$1 not available in this environment"
  fi
}

# ── Claude Code plugin validation ──────────────────────────────

@test "claude plugin validate passes" {
  skip_if_missing claude
  run claude plugin validate .
  [ "$status" -eq 0 ]
}

@test "plugin.json exists and is valid JSON" {
  run jq empty .claude-plugin/plugin.json
  [ "$status" -eq 0 ]
}

@test "plugin.json has required fields" {
  run jq -e '.name' .claude-plugin/plugin.json
  [ "$status" -eq 0 ]
  run jq -e '.version' .claude-plugin/plugin.json
  [ "$status" -eq 0 ]
  run jq -e '.description' .claude-plugin/plugin.json
  [ "$status" -eq 0 ]
}

@test "plugin.json userConfig has sensitive token" {
  run jq -e '.userConfig.massive_token.sensitive == true' .claude-plugin/plugin.json
  [ "$status" -eq 0 ]
}

@test "marketplace.json exists and is valid JSON" {
  run jq empty .claude-plugin/marketplace.json
  [ "$status" -eq 0 ]
}

@test "marketplace.json declares massive plugin" {
  run jq -e '.plugins[0].name == "massive"' .claude-plugin/marketplace.json
  [ "$status" -eq 0 ]
}

# ── skills.sh validation ───────────────────────────────────────

@test "skills CLI is available and can list installed skills" {
  skip_if_missing skills
  run skills list
  [ "$status" -eq 0 ]
}

@test "SKILL.md exists and has YAML frontmatter" {
  run head -1 skills/massive/SKILL.md
  [ "$output" = "---" ]
}

@test "SKILL.md frontmatter has name field" {
  run grep -q '^name:' skills/massive/SKILL.md
  [ "$status" -eq 0 ]
}

@test "SKILL.md frontmatter has description field" {
  run grep -q '^description:' skills/massive/SKILL.md
  [ "$status" -eq 0 ]
}

# ── Reference files ────────────────────────────────────────────

@test "all reference files present" {
  for ref in browser.md search.md ai.md; do
    [ -f "skills/massive/references/$ref" ]
  done
}

@test "SKILL.md links point to existing files" {
  while IFS= read -r target; do
    [ -f "skills/massive/$target" ]
  done < <(sed -n 's/.*](\(references\/[^)]*\)).*/\1/p' skills/massive/SKILL.md)
}

# ── README ─────────────────────────────────────────────────────

@test "README.md exists" {
  [ -f "README.md" ]
}
