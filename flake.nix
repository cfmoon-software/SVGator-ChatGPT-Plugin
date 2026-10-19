{
  description = "CFMoon SVGator for ChatGPT template development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              bashInteractive
              jq
              shellcheck
              zip
              unzip
            ];
          };
        }
      );

      checks = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          source = ./.;
        in
        {
          template = pkgs.runCommand "cfmoon-svgator-chatgpt-template-check" {
            nativeBuildInputs = with pkgs; [
              bash
              jq
              shellcheck
              zip
              unzip
            ];
          } ''
            test ! -e ${source}/.app.json
            test ! -e ${source}/mcp.json
            test ! -e ${source}/.mcp.json
            test -e ${source}/LICENSE
            test -e ${source}/assets/README.md

            bash -n ${source}/scripts/prepare-chatgpt-plugin.sh
            shellcheck ${source}/scripts/prepare-chatgpt-plugin.sh

            archive_name="$(${pkgs.jq}/bin/jq -r '.name + "-" + .version + ".zip"' ${source}/plugin.json)"
            archive_path="$TMPDIR/private-plugin/$archive_name"

            ${pkgs.bash}/bin/bash ${source}/scripts/prepare-chatgpt-plugin.sh \
              asdk_app_NixCheck123 \
              "$TMPDIR/private-plugin"

            test -f "$archive_path"
            unzip -t "$archive_path"
            test "$(unzip -Z1 "$archive_path" | wc -l)" -eq 8
            ! unzip -Z1 "$archive_path" \
              | grep -Eq '(^|/)(LICENSE|README\.md)$'
            unzip -p "$archive_path" plugin.json \
              | jq -e '.name == "cfmoon-svgator-animations-chatgpt" and .license == "Apache-2.0"'
            unzip -p "$archive_path" plugin.json \
              | jq -e '.extensions["com.openai"].interface.defaultPrompt[0] == "Verify my SVGator connection without creating, editing, or exporting any projects."'
            test "$(unzip -p "$archive_path" plugin.json | jq -r '.version')" = \
              "$(unzip -p "$archive_path" .codex-plugin/plugin.json | jq -r '.version')"
            test "$(unzip -p "$archive_path" plugin.json | jq -c '.extensions["com.openai"].interface.defaultPrompt')" = \
              "$(unzip -p "$archive_path" .codex-plugin/plugin.json | jq -c '.interface.defaultPrompt')"
            unzip -p "$archive_path" .app.json \
              | jq -e '.apps.svgator.id == "asdk_app_NixCheck123"'

            if ${pkgs.bash}/bin/bash ${source}/scripts/prepare-chatgpt-plugin.sh \
              asdk_app_NixCheck123 \
              "$TMPDIR/wrong-version-0.0.0.zip"; then
              echo 'builder accepted an explicit filename with the wrong version' >&2
              exit 1
            fi

            touch "$out"
          '';
        }
      );
    };
}
