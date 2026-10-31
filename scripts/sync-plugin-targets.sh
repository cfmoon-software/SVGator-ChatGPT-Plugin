#!/usr/bin/env bash
# Render committed host targets from the canonical root plugin sources.
set -euo pipefail

usage() {
  printf '%s\n' \
    'Usage:' \
    '  ./scripts/sync-plugin-targets.sh' \
    '  ./scripts/sync-plugin-targets.sh --check'
}

mode='write'
if [[ $# -gt 1 ]]; then
  usage >&2
  exit 2
fi
if [[ $# -eq 1 ]]; then
  if [[ $1 != --check ]]; then
    usage >&2
    exit 2
  fi
  mode='check'
fi

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' 'Error: jq is required to synchronize plugin targets.' >&2
  exit 1
fi

repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
overrides="$repo_dir/config/codex-plugin-overrides.json"
mcp_manifest="$repo_dir/codex/mcp.json"
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/cfmoon-plugin-sync.XXXXXX")

cleanup() {
  chmod -R u+w -- "$work_dir" 2>/dev/null || true
  rm -rf -- "$work_dir"
}
trap cleanup EXIT

render_dir="$work_dir/rendered"
mkdir -p -- \
  "$render_dir/.codex-plugin" \
  "$render_dir/codex/.codex-plugin" \
  "$render_dir/codex/assets" \
  "$render_dir/codex/skills/svgator-animate/agents" \
  "$render_dir/codex/skills/svgator-audit/agents"

jq -e '
  type == "object" and
  (.name | type == "string" and length > 0) and
  (.description | type == "string" and length > 0) and
  (.displayName | type == "string" and length > 0) and
  (.longDescription | type == "string" and length > 0)
' "$overrides" >/dev/null

render_compatibility_manifest() {
  jq '
    (if .extensions["com.openai"] | has("apps") then
      {apps: .extensions["com.openai"].apps}
    else
      {}
    end) +
    {
      interface: .extensions["com.openai"].interface,
      requires_local_executor: .extensions["com.openai"].requires_local_executor,
      extensions: {
        "com.openai": {
          onboardingSkill: .extensions["com.openai"].onboardingSkill
        }
      },
      name,
      version,
      description,
      author,
      keywords,
      license,
      skills: "./skills/"
    }
  ' "$1" > "$2"
}

render_compatibility_manifest \
  "$repo_dir/plugin.json" \
  "$render_dir/.codex-plugin/plugin.json"

jq --slurpfile target "$overrides" '
  .name = $target[0].name |
  .description = $target[0].description |
  del(.extensions["com.openai"].apps) |
  .extensions["com.openai"].interface.displayName = $target[0].displayName |
  .extensions["com.openai"].interface.longDescription = $target[0].longDescription
' "$repo_dir/plugin.json" > "$render_dir/codex/plugin.json"

render_compatibility_manifest \
  "$render_dir/codex/plugin.json" \
  "$render_dir/codex/.codex-plugin/plugin.json"

cp -- \
  "$repo_dir/assets/cfmoon-svgator-animations.png" \
  "$render_dir/codex/assets/cfmoon-svgator-animations.png"

server_name=$(jq -er '
  .mcpServers | keys |
  if length == 1 then .[0] else error("expected exactly one MCP server") end
' "$mcp_manifest")
server_type=$(jq -er --arg server "$server_name" \
  '.mcpServers[$server].type | strings' "$mcp_manifest")
server_url=$(jq -er --arg server "$server_name" \
  '.mcpServers[$server].url | strings' "$mcp_manifest")
agent_transport=${server_type//-/_}

for skill in svgator-animate svgator-audit; do
  cp -- \
    "$repo_dir/skills/$skill/SKILL.md" \
    "$render_dir/codex/skills/$skill/SKILL.md"
  cp -- \
    "$repo_dir/skills/$skill/agents/openai.yaml" \
    "$render_dir/codex/skills/$skill/agents/openai.yaml"
  chmod u+w -- "$render_dir/codex/skills/$skill/agents/openai.yaml"
  printf '\ndependencies:\n  tools:\n    - type: "mcp"\n      value: "%s"\n      description: "SVGator hosted MCP server"\n      transport: "%s"\n      url: "%s"\n' \
    "$server_name" "$agent_transport" "$server_url" \
    >> "$render_dir/codex/skills/$skill/agents/openai.yaml"
done

generated_paths=(
  .codex-plugin/plugin.json
  codex/plugin.json
  codex/.codex-plugin/plugin.json
  codex/assets/cfmoon-svgator-animations.png
  codex/skills/svgator-animate/SKILL.md
  codex/skills/svgator-animate/agents/openai.yaml
  codex/skills/svgator-audit/SKILL.md
  codex/skills/svgator-audit/agents/openai.yaml
)

if [[ $mode == check ]]; then
  stale=0
  for path in "${generated_paths[@]}"; do
    if ! cmp -s -- "$render_dir/$path" "$repo_dir/$path"; then
      printf 'Generated file is stale: %s\n' "$path" >&2
      stale=1
    fi
  done
  if [[ $stale -ne 0 ]]; then
    printf '%s\n' 'Run ./scripts/sync-plugin-targets.sh and review the generated changes.' >&2
    exit 1
  fi
  printf '%s\n' 'Generated plugin targets are synchronized.'
  exit 0
fi

for path in "${generated_paths[@]}"; do
  mkdir -p -- "$repo_dir/${path%/*}"
  cp -- "$render_dir/$path" "$repo_dir/$path"
done

printf 'Synchronized %s generated plugin target files.\n' "${#generated_paths[@]}"
