#!/usr/bin/env bash
# Validate the installable Codex target without changing user configuration.
set -euo pipefail

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
codex_dir="$repo_dir/codex"

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' 'Missing Codex test dependency: jq' >&2
  exit 1
fi

test -f "$codex_dir/plugin.json"
test -f "$codex_dir/mcp.json"
test -f "$codex_dir/.codex-plugin/plugin.json"
test -f "$repo_dir/.agents/plugins/marketplace.json"
test ! -e "$codex_dir/.app.json"

bash "$repo_dir/scripts/sync-plugin-targets.sh" --check

expected_paths=$(printf '%s\n' \
  .codex-plugin/plugin.json \
  README.md \
  assets/cfmoon-svgator-animations.png \
  mcp.json \
  plugin.json \
  skills/svgator-animate/SKILL.md \
  skills/svgator-animate/agents/openai.yaml \
  skills/svgator-audit/SKILL.md \
  skills/svgator-audit/agents/openai.yaml \
  skills/svgator-setup/SKILL.md \
  skills/svgator-setup/agents/openai.yaml | LC_ALL=C sort)
actual_paths=$(
  cd -- "$codex_dir"
  find . -type f | sed 's#^\./##' | LC_ALL=C sort
)
if [[ "$expected_paths" != "$actual_paths" ]]; then
  printf '%s\n' 'Codex target content differs from its eleven-file allowlist.' >&2
  diff -u <(printf '%s\n' "$expected_paths") <(printf '%s\n' "$actual_paths") >&2 || true
  exit 1
fi

jq -e '
  .mcpServers.svgator.type == "streamable-http" and
  .mcpServers.svgator.url == "https://mcp.svgator.com/mcp" and
  .mcpServers.svgator.extensions["com.openai"].auth.type == "oauth" and
  .mcpServers.svgator.extensions["com.openai"].auth.client.mode == "dcr" and
  (.mcpServers.svgator.extensions["com.openai"].auth.client | has("clientId") | not)
' "$codex_dir/mcp.json" >/dev/null

jq -e '
  .name == "cfmoon-svgator-animations" and
  .source.source == "local" and
  .source.path == "./codex" and
  .policy.installation == "AVAILABLE" and
  .policy.authentication == "ON_INSTALL" and
  .category == "Productivity"
' < <(jq '.plugins[0]' "$repo_dir/.agents/plugins/marketplace.json") >/dev/null

chatgpt_version=$(jq -er '.version' "$repo_dir/plugin.json")
codex_version=$(jq -er '.version' "$codex_dir/plugin.json")
test "$codex_version" = "$chatgpt_version"

root_shared=$(jq -cS '{
  name, version, description, author, keywords, license,
  interface: .extensions["com.openai"].interface,
  onboardingSkill: .extensions["com.openai"].onboardingSkill,
  requires_local_executor: .extensions["com.openai"].requires_local_executor
}' "$codex_dir/plugin.json")
overlay_shared=$(jq -cS '{
  name, version, description, author, keywords, license, interface,
  onboardingSkill: .extensions["com.openai"].onboardingSkill,
  requires_local_executor
}' "$codex_dir/.codex-plugin/plugin.json")
if [[ "$root_shared" != "$overlay_shared" ]]; then
  printf '%s\n' 'Codex manifests have drifted out of sync.' >&2
  exit 1
fi

jq -e '
  .name == "cfmoon-svgator-animations" and
  (.extensions["com.openai"] | has("apps") | not) and
  .extensions["com.openai"].onboardingSkill == "./skills/svgator-setup/SKILL.md"
' "$codex_dir/plugin.json" >/dev/null

for skill in svgator-animate svgator-audit svgator-setup; do
  grep -Fq 'value: "svgator"' "$codex_dir/skills/$skill/agents/openai.yaml"
  grep -Fq 'url: "https://mcp.svgator.com/mcp"' \
    "$codex_dir/skills/$skill/agents/openai.yaml"
done

if grep -R -E '(^|[^A-Za-z0-9_])(plugin_)?asdk_app_[A-Za-z0-9]' "$codex_dir" >/dev/null; then
  printf '%s\n' 'Codex target contains a ChatGPT App identifier.' >&2
  exit 1
fi

printf 'Codex package checks passed: %s (%s entries)\n' \
  "cfmoon-svgator-animations-$codex_version" \
  "$(printf '%s\n' "$actual_paths" | wc -l | tr -d ' ')"
