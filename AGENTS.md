# CFMoon SVGator Monorepo Agent Instructions

## Repository purpose

This repository distributes two independent CFMoon integrations around
SVGator's hosted MCP server: a template for building a private ChatGPT plugin
backed by a custom SVGator App, and a neutral installable Codex plugin. It is
not an official SVGator integration and must not imply affiliation with or
endorsement by SVGator.

The repository itself and the Codex target are public and reusable. Each
generated ChatGPT plugin ZIP is private because it contains the installing
user's ChatGPT App reference.

## Source of truth

- `README.md` is authoritative for the user-facing setup and test flow.
- `plugin.json` owns the portable plugin identity, version, publisher metadata,
  presentation, and private App dependency declaration.
- `assets/cfmoon-svgator-animations.png` and the root animation and audit skills
  are canonical shared sources.
- `config/codex-plugin-overrides.json` owns the Codex identity and presentation
  values that intentionally differ from the root manifest.
- `scripts/sync-plugin-targets.sh` generates the root compatibility manifest,
  both Codex manifests, and the shared Codex icon, animation, and audit files.
  The generated files remain committed for zero-build installation.
- `scripts/prepare-chatgpt-plugin.sh` is the only supported package builder.
- `scripts/test-package.sh` is the portable validation suite used by CI and Nix.
- `codex/mcp.json` owns the single direct SVGator MCP connection used by Codex.
- The Codex setup skill, its agent metadata, and `codex/README.md` are
  host-owned rather than generated.
- `.agents/plugins/marketplace.json` exposes the Codex target to the repository
  marketplace.
- `scripts/test-codex-package.sh` validates the Codex package and marketplace.
- `skills/` contains the reusable SVGator workflows. Preserve their names and
  invocation intent unless a requested change explicitly updates them.
- `LICENSE` applies Apache-2.0 to the code, documentation, configuration, and
  skills. `assets/README.md` separately governs the CFMoon artwork and branding.

## Security and distribution invariants

- Never add or commit a real `.app.json`, `asdk_app_...` value, OAuth token,
  cookie, password, client secret, or authenticated session.
- Use only obvious synthetic IDs such as `asdk_app_Test123` in checks.
- Keep `/.app.json` and generated private ZIPs ignored by Git.
- Do not add root-level `mcp.json` or `.mcp.json` to the ChatGPT template. The
  generated ChatGPT plugin must use exactly one connection path: the user's
  registered ChatGPT App through `.app.json`.
- The Codex target must contain no `.app.json` or ChatGPT App ID. It uses
  exactly one connection path: `codex/mcp.json` pointing to SVGator's hosted
  Streamable HTTP endpoint with OAuth/DCR.
- The generated private plugin ZIP must contain exactly these ten files:
  `plugin.json`, `.app.json`, `.codex-plugin/plugin.json`, the icon, all three
  `SKILL.md` files, and all three `agents/openai.yaml` files.
- Do not add `LICENSE`, `assets/README.md`, or other licensing files to the
  generated private ZIP. The asset notice grants the limited permission needed
  to include the unmodified icon in that archive.
- Do not publish, attach to a release, or commit a generated private ZIP.
- A GitHub release asset is the neutral monorepo source archive, never the
  personalized ChatGPT upload archive.
- Keep the CFMoon publisher identity and the independent-integration disclaimer.
- Keep the icon excluded from Apache-2.0. The manifest license field describes
  the reusable implementation and does not override `assets/README.md`.
- Keep the Codex target self-contained and its marketplace source path at
  `./codex`. Do not use symlinks or paths that escape the plugin root.
- External uploads, GitHub releases, workspace changes, and ChatGPT publication
  require explicit user approval.

## Change workflow

1. Inspect the working tree and preserve unrelated user work.
2. Make the smallest change needed in the repository source.
3. Edit canonical sources and target overrides, then run
   `scripts/sync-plugin-targets.sh`. Do not hand-edit generated files. Keep
   target versions aligned for a shared release.
4. Keep `README.md` instructions aligned with actual script behavior.
5. Run the focused checks below with synthetic data. They validate both host
   targets.
6. Rebuild and inspect the neutral template archive after any source change.
7. Report host behavior separately from local package verification. A valid ZIP
   does not prove that ChatGPT or SVGator authorization works.

## Verification

Run either of these equivalent checks:

```sh
nix flake check
# or, with Bash, jq, ShellCheck, zip and unzip installed:
bash scripts/test-package.sh
```

Inspect archive paths without printing `.app.json`. The test asserts the exact
ten-file ChatGPT allowlist, the eleven-file Codex allowlist, synchronized
generated files, ID normalization, marketplace and OAuth/DCR configuration,
and safe failures.

## Release discipline

- Follow semantic versioning, keep both manifests for each target synchronized,
  and keep ChatGPT and Codex versions aligned for shared releases.
- Keep the Apache-2.0 `LICENSE`, the separate `assets/README.md` notice, and the
  manifest metadata intact.
- Build the neutral monorepo source archive outside the repository directory so the
  archive cannot include itself.
- Include both `LICENSE` and `assets/README.md` in the neutral repository
  template archive; they are excluded only from the personalized upload ZIP.
- Record the release archive's SHA-256 checksum.
- Never reuse a successful host test as evidence for a later release; rerun the
  synthetic package check and ask the tester to verify ChatGPT separately.
