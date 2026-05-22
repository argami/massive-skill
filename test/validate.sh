#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0

pass() { echo "  ✅ $1"; PASS=$((PASS + 1)); }
fail() { echo "  ❌ $1"; FAIL=$((FAIL + 1)); }

echo "=== plugin.json validation ==="

PLUGIN_JSON="$ROOT/.claude-plugin/plugin.json"
if [[ -f "$PLUGIN_JSON" ]]; then
  pass "plugin.json exists"
else
  fail "plugin.json missing"
fi

# Validate JSON syntax
if jq empty "$PLUGIN_JSON" 2>/dev/null; then
  pass "plugin.json is valid JSON"
else
  fail "plugin.json is not valid JSON"
fi

# Required fields
for field in name version description; do
  if jq -e ".$field" "$PLUGIN_JSON" > /dev/null 2>&1; then
    pass "plugin.json has '$field'"
  else
    fail "plugin.json missing '$field'"
  fi
done

# userConfig structure
if jq -e '.userConfig.massive_token' "$PLUGIN_JSON" > /dev/null 2>&1; then
  pass "userConfig.massive_token exists"
  if jq -e '.userConfig.massive_token.sensitive == true' "$PLUGIN_JSON" > /dev/null 2>&1; then
    pass "massive_token marked as sensitive"
  else
    fail "massive_token should be sensitive: true"
  fi
else
  fail "userConfig.massive_token missing"
fi

# marketplace.json
MARKETPLACE_JSON="$ROOT/.claude-plugin/marketplace.json"
if [[ -f "$MARKETPLACE_JSON" ]]; then
  pass "marketplace.json exists"
else
  fail "marketplace.json missing"
fi

if jq empty "$MARKETPLACE_JSON" 2>/dev/null; then
  pass "marketplace.json is valid JSON"
else
  fail "marketplace.json is not valid JSON"
fi

if jq -e '.plugins[0].name == "massive"' "$MARKETPLACE_JSON" > /dev/null 2>&1; then
  pass "marketplace.json declares massive plugin"
else
  fail "marketplace.json missing massive plugin entry"
fi

# skills/ directory is auto-discovered by Claude Code
if [[ -d "$ROOT/skills/massive" ]]; then
  pass "skills/massive directory exists (auto-discovered)"
else
  fail "skills/massive directory missing"
fi

echo ""
echo "=== SKILL.md validation ==="

SKILL_MD="$ROOT/skills/massive/SKILL.md"
if [[ -f "$SKILL_MD" ]]; then
  pass "SKILL.md exists"
else
  fail "SKILL.md missing at skills/massive/SKILL.md"
fi

# Check YAML frontmatter (starts with ---)
if head -1 "$SKILL_MD" | grep -q '^---$'; then
  pass "SKILL.md has YAML frontmatter delimiter"
else
  fail "SKILL.md missing YAML frontmatter (must start with ---)"
fi

# Extract frontmatter and validate required fields
FRONTMATTER=$(sed -n '/^---$/,/^---$/p' "$SKILL_MD")
for field in name description; do
  if echo "$FRONTMATTER" | grep -q "^$field:"; then
    pass "SKILL.md frontmatter has '$field'"
  else
    fail "SKILL.md frontmatter missing '$field'"
  fi
done

echo ""
echo "=== Directory structure validation ==="

# Expected directories
for dir in "skills/massive" "skills/massive/references"; do
  if [[ -d "$ROOT/$dir" ]]; then
    pass "directory exists: $dir"
  else
    fail "directory missing: $dir"
  fi
done

# Expected reference files
for ref in browser.md search.md ai.md; do
  if [[ -f "$ROOT/skills/massive/references/$ref" ]]; then
    pass "reference file exists: references/$ref"
  else
    fail "reference file missing: references/$ref"
  fi
done

echo ""
echo "=== Reference integrity ==="

# Check all links in SKILL.md point to existing files (macOS + Linux compatible)
while IFS= read -r target; do
  if [[ -f "$ROOT/skills/massive/$target" ]]; then
    pass "link target exists: $target"
  else
    fail "broken link: $target"
  fi
done < <(sed -n 's/.*](\(references\/[^)]*\)).*/\1/p' "$SKILL_MD" || true)

echo ""
echo "=== README exists ==="
if [[ -f "$ROOT/README.md" ]]; then
  pass "README.md exists"
else
  fail "README.md missing"
fi

echo ""
echo "---"
echo "Results: $PASS passed, $FAIL failed"
if [[ $FAIL -gt 0 ]]; then
  exit 1
fi
