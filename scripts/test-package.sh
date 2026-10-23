#!/usr/bin/env bash
# Validate the portable template and exercise the exact private-ZIP contract.
# Uses synthetic App IDs only; never needs OAuth or a real ChatGPT connection.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)

for tool in jq shellcheck zip unzip; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf 'Missing test dependency: %s\n' "$tool" >&2
    exit 1
  fi
done

test ! -e "$repo_dir/.app.json"
test ! -e "$repo_dir/mcp.json"
test ! -e "$repo_dir/.mcp.json"
test -f "$repo_dir/LICENSE"
test -f "$repo_dir/assets/README.md"
test -f "$repo_dir/assets/signal-strike-demo.gif"
for doc in development troubleshooting updating; do
  test -f "$repo_dir/docs/$doc.md"
done

bash -n "$repo_dir/scripts/prepare-chatgpt-plugin.sh"
shellcheck "$repo_dir/scripts/prepare-chatgpt-plugin.sh"
bash -n "$repo_dir/scripts/test-package.sh"
shellcheck "$repo_dir/scripts/test-package.sh"

# Verify all portable metadata duplicated across the two different manifest layouts.
jq -e 'type == "object" and (.name | type == "string") and (.version | type == "string")' \
  "$repo_dir/plugin.json" >/dev/null
jq -e 'type == "object"' "$repo_dir/.codex-plugin/plugin.json" >/dev/null

root_shared=$(jq -cS '{
  name, version, description, author, keywords, license,
  apps: .extensions["com.openai"].apps,
  interface: .extensions["com.openai"].interface,
  onboardingSkill: .extensions["com.openai"].onboardingSkill,
  requires_local_executor: .extensions["com.openai"].requires_local_executor
}' "$repo_dir/plugin.json")
codex_shared=$(jq -cS '{
  name, version, description, author, keywords, license, apps, interface,
  onboardingSkill: .extensions["com.openai"].onboardingSkill,
  requires_local_executor
}' "$repo_dir/.codex-plugin/plugin.json")

if [[ "$root_shared" != "$codex_shared" ]]; then
  printf '%s\n' 'Plugin manifests have drifted out of sync.' >&2
  exit 1
fi

plugin_name=$(jq -er '.name' "$repo_dir/plugin.json")
plugin_version=$(jq -er '.version' "$repo_dir/plugin.json")
test "$plugin_name" = 'cfmoon-svgator-animations-chatgpt'

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/cfmoon-plugin-test.XXXXXX")
trap 'rm -rf -- "$work_dir"' EXIT

builder="$repo_dir/scripts/prepare-chatgpt-plugin.sh"
archive="$work_dir/current/$plugin_name-$plugin_version.zip"
bash "$builder" asdk_app_Test123 "$work_dir/current" >/dev/null
test -f "$archive"
unzip -t "$archive" >/dev/null

expected_paths=$(printf '%s\n' \
  plugin.json \
  .app.json \
  .codex-plugin/plugin.json \
  assets/cfmoon-svgator-animations.png \
  skills/svgator-animate/SKILL.md \
  skills/svgator-animate/agents/openai.yaml \
  skills/svgator-audit/SKILL.md \
  skills/svgator-audit/agents/openai.yaml \
  skills/svgator-setup/SKILL.md \
  skills/svgator-setup/agents/openai.yaml | LC_ALL=C sort)
actual_paths=$(unzip -Z1 "$archive" | LC_ALL=C sort)
if [[ "$expected_paths" != "$actual_paths" ]]; then
  printf '%s\n' 'ZIP content differs from the ten-file allowlist.' >&2
  diff -u <(printf '%s\n' "$expected_paths") <(printf '%s\n' "$actual_paths") >&2 || true
  exit 1
fi

unzip -p "$archive" .app.json | jq -e '.apps.svgator.id == "asdk_app_Test123"' >/dev/null
unzip -p "$archive" skills/svgator-audit/SKILL.md | grep -Fq 'name: svgator-audit'
unzip -p "$archive" skills/svgator-audit/agents/openai.yaml | grep -Fq 'svgator-audit'
unzip -p "$archive" plugin.json | jq -e --arg version "$plugin_version" \
  '.version == $version and .extensions["com.openai"].apps == "./.app.json"' >/dev/null
unzip -p "$archive" .codex-plugin/plugin.json | jq -e --arg version "$plugin_version" \
  '.version == $version and .apps == "./.app.json"' >/dev/null

# The documented, prefixed App ID form must normalize to the same binding.
bash "$builder" plugin_asdk_app_Test123 "$work_dir/prefixed" >/dev/null
unzip -p "$work_dir/prefixed/$plugin_name-$plugin_version.zip" .app.json \
  | jq -e '.apps.svgator.id == "asdk_app_Test123"' >/dev/null

# Invalid IDs, misleading archive versions, and overwrites must fail.
for invalid_id in invalid_app_id asdk_app_ 'asdk_app_Bad/Path'; do
  if bash "$builder" "$invalid_id" "$work_dir/invalid" >/dev/null 2>&1; then
    printf 'Builder accepted invalid App ID: %s\n' "$invalid_id" >&2
    exit 1
  fi
done
if bash "$builder" asdk_app_Test123 "$work_dir/wrong-version-0.0.0.zip" \
  >/dev/null 2>&1; then
  printf '%s\n' 'Builder accepted misleading ZIP filename.' >&2
  exit 1
fi
if bash "$builder" asdk_app_Test123 "$work_dir/current" >/dev/null 2>&1; then
  printf '%s\n' 'Builder overwrote an existing ZIP.' >&2
  exit 1
fi

printf 'Package checks passed: %s (%s entries)\n' \
  "$plugin_name-$plugin_version.zip" "$(unzip -Z1 "$archive" | wc -l | tr -d ' ')"
