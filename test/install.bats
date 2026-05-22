#!/usr/bin/env bats

ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"

setup() {
  cd "$ROOT"
}

skip_if_missing() {
  if ! command -v "$1" &>/dev/null; then
    skip "$1 not available in this environment"
  fi
}

# ── Structural checks ──────────────────────────────────────────

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

@test "SKILL.md exists and has YAML frontmatter" {
  run head -1 skills/massive/SKILL.md
  [ "$output" = "---" ]
}

@test "SKILL.md frontmatter has name and description" {
  run grep -q '^name:' skills/massive/SKILL.md
  [ "$status" -eq 0 ]
  run grep -q '^description:' skills/massive/SKILL.md
  [ "$status" -eq 0 ]
}

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

@test "README.md exists" {
  [ -f "README.md" ]
}

# ── Claude Code plugin E2E install test ────────────────────────

@test "claude plugin marketplace-add + install + verify + cleanup" {
  skip_if_missing claude

  # Clean up from any previous failed test run
  claude plugin uninstall massive 2>/dev/null || true
  claude plugin marketplace remove massive-skill 2>/dev/null || true

  # Add repo as marketplace (must use absolute path)
  run claude plugin marketplace add "$ROOT"
  [ "$status" -eq 0 ]

  # Install the plugin
  run claude plugin install massive
  [ "$status" -eq 0 ]

  # Verify it appears in the installed list
  run claude plugin list
  [ "$status" -eq 0 ]
  [[ "$output" =~ massive ]]

  # Cleanup
  run claude plugin uninstall massive
  [ "$status" -eq 0 ]
  run claude plugin marketplace remove massive-skill
  [ "$status" -eq 0 ]
}

# ── skills.sh E2E install test ─────────────────────────────────

@test "skills add + verify + cleanup from git URL" {
  skip_if_missing skills

  # Clean up from any previous failed test run
  skills uninstall massive-skill --global 2>/dev/null || true

  local remote
  remote=$(git remote get-url origin)

  run skills add "$remote" --global --skip-setup
  [ "$status" -eq 0 ]

  # Verify it appears in the global installed list
  run skills list --global
  [ "$status" -eq 0 ]
  [[ "$output" =~ massive-skill ]]

  # Cleanup
  run skills uninstall massive-skill --global
  [ "$status" -eq 0 ]
}
