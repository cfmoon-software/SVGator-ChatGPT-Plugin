#!/usr/bin/env bash

set -euo pipefail

usage() {
  printf '%s\n' \
    'Usage:' \
    '  ./scripts/prepare-chatgpt-plugin.sh <ChatGPT-App-ID> [output-directory|output.zip]' \
    '' \
    'Output:' \
    '  Omit the second argument to write a versioned archive under ./dist/.' \
    '  Pass a directory to create it and use the manifest-derived filename.' \
    '  Pass a .zip path only when its filename includes the manifest version.' \
    '' \
    'Accepted App ID forms:' \
    '  asdk_app_...         (shown in the tested ChatGPT workspace UI)' \
    '  plugin_asdk_app_...  (compatibility form documented by OpenAI)'
}

if [[ $# -lt 1 || $# -gt 2 ]]; then
  usage >&2
  exit 2
fi

input_app_id=$1
output_argument=${2:-./dist}

case "$input_app_id" in
  asdk_app_*) manifest_app_id=$input_app_id ;;
  plugin_asdk_app_*) manifest_app_id=${input_app_id#plugin_} ;;
  *)
    printf '%s\n' 'Error: expected an App ID beginning with asdk_app_ or plugin_asdk_app_.' >&2
    exit 2
    ;;
esac

if [[ ! "$manifest_app_id" =~ ^asdk_app_[A-Za-z0-9][A-Za-z0-9_-]*$ ]]; then
  printf '%s\n' 'Error: the App ID contains unsupported characters or has no identifier suffix.' >&2
  exit 2
fi

if ! command -v jq >/dev/null 2>&1; then
  printf '%s\n' 'Error: jq is required to read the plugin manifests.' >&2
  exit 1
fi

if ! command -v zip >/dev/null 2>&1; then
  printf '%s\n' 'Error: zip is required to prepare the ChatGPT plugin archive.' >&2
  exit 1
fi

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
template_dir=$(cd -- "$script_dir/.." && pwd)

if ! plugin_name=$(jq -er '.name | strings' "$template_dir/plugin.json"); then
  printf '%s\n' 'Error: could not read one top-level plugin name from plugin.json.' >&2
  exit 1
fi

if ! plugin_version=$(jq -er '.version | strings' "$template_dir/plugin.json"); then
  printf '%s\n' 'Error: could not read one top-level plugin version from plugin.json.' >&2
  exit 1
fi

if [[ ! "$plugin_name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  printf '%s\n' 'Error: the plugin name cannot be used safely in an archive filename.' >&2
  exit 1
fi

if [[ ! "$plugin_version" =~ ^[A-Za-z0-9][A-Za-z0-9._+-]*$ ]]; then
  printf '%s\n' 'Error: the plugin version cannot be used safely in an archive filename.' >&2
  exit 1
fi

archive_filename="$plugin_name-$plugin_version.zip"

case "$output_argument" in
  /*) output_target=$output_argument ;;
  *) output_target="$(pwd)/$output_argument" ;;
esac

case "$output_target" in
  *.zip)
    output_path=$output_target
    output_basename=${output_path##*/}
    if [[ "$output_basename" != *-"$plugin_version".zip ]]; then
      printf 'Error: the output filename must include manifest version %s (for example, %s).\n' \
        "$plugin_version" "$archive_filename" >&2
      exit 2
    fi
    ;;
  *)
    output_dir=${output_target%/}
    output_path="$output_dir/$archive_filename"
    ;;
esac

if [[ -e "$output_path" ]]; then
  printf 'Error: refusing to overwrite existing output: %s\n' "$output_path" >&2
  exit 1
fi

output_dir=${output_path%/*}
mkdir -p -- "$output_dir"

work_dir=$(mktemp -d "${TMPDIR:-/tmp}/cfmoon-svgator-chatgpt.XXXXXX")
package_dir="$work_dir/cfmoon-svgator-animations-chatgpt"

cleanup() {
  # Sources may come from a read-only store (for example, a Nix flake check).
  chmod -R u+w -- "$work_dir" 2>/dev/null || true
  rm -rf -- "$work_dir"
}
trap cleanup EXIT

mkdir -p -- "$package_dir/.codex-plugin" "$package_dir/assets"
cp -R -- "$template_dir/skills" "$package_dir/skills"
cp -- "$template_dir/plugin.json" "$package_dir/plugin.json"
cp -- "$template_dir/.codex-plugin/plugin.json" "$package_dir/.codex-plugin/plugin.json"
cp -- "$template_dir/assets/cfmoon-svgator-animations.png" "$package_dir/assets/cfmoon-svgator-animations.png"

printf '{\n  "apps": {\n    "svgator": {\n      "id": "%s"\n    }\n  }\n}\n' \
  "$manifest_app_id" > "$package_dir/.app.json"

(
  cd -- "$package_dir"
  zip -X -q "$output_path" \
    plugin.json \
    .app.json \
    .codex-plugin/plugin.json \
    assets/cfmoon-svgator-animations.png \
    skills/svgator-animate/SKILL.md \
    skills/svgator-animate/agents/openai.yaml \
    skills/svgator-audit/SKILL.md \
    skills/svgator-audit/agents/openai.yaml \
    skills/svgator-setup/SKILL.md \
    skills/svgator-setup/agents/openai.yaml
)

printf 'Created private ChatGPT plugin archive: %s\n' "$output_path"
printf '%s\n' 'The App ID was embedded without being printed. Do not publish the generated ZIP.'
