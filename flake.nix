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
              coreutils
              diffutils
              jq
              shellcheck
              zip
              unzip
            ];
          } ''
            ${pkgs.bash}/bin/bash ${source}/scripts/test-package.sh
            touch "$out"
          '';
        }
      );
    };
}
