# CFMoon SVGator ChatGPT Template Agent Instructions

## Repository purpose

This repository distributes an independent CFMoon template for building a
private ChatGPT plugin backed by a custom SVGator App. It is not an official
SVGator integration and must not imply affiliation with or endorsement by
SVGator.

The repository itself is public and reusable. Each generated plugin ZIP is
private because it contains the installing user's ChatGPT App reference.

## Source of truth

- `README.md` is authoritative for the user-facing setup and test flow.
- `plugin.json` owns the portable plugin identity, version, publisher metadata,
  presentation, and private App dependency declaration.
- `.codex-plugin/plugin.json` is a compatibility manifest. Keep its repeated
  identity, version, presentation, and App dependency synchronized with the
  root manifest.
- `scripts/prepare-chatgpt-plugin.sh` is the only supported package builder.
- `skills/` contains the reusable SVGator workflows. Preserve their names and
  invocation intent unless a requested change explicitly updates them.
- `LICENSE` applies Apache-2.0 to the code, documentation, configuration, and
  skills. `assets/README.md` separately governs the CFMoon artwork and branding.

## Security and distribution invariants

- Never add or commit a real `.app.json`, `asdk_app_...` value, OAuth token,
  cookie, password, client secret, or authenticated session.
- Use only obvious synthetic IDs such as `asdk_app_Test123` in checks.
- Keep `/.app.json` and generated private ZIPs ignored by Git.
- Do not add `mcp.json` or `.mcp.json` to this ChatGPT template. The generated
  plugin must use exactly one connection path: the user's registered ChatGPT
  App through `.app.json`.
- The generated private plugin ZIP must contain exactly these eight files:
  `plugin.json`, `.app.json`, `.codex-plugin/plugin.json`, the icon, both
  `SKILL.md` files, and both `agents/openai.yaml` files.
- Do not add `LICENSE`, `assets/README.md`, or other licensing files to the
  generated private ZIP. The asset notice grants the limited permission needed
  to include the unmodified icon in that archive.
- Do not publish, attach to a release, or commit a generated private ZIP.
- A GitHub release asset is the neutral repository template archive, never the
  personalized ChatGPT upload archive.
- Keep the CFMoon publisher identity and the independent-integration disclaimer.
- Keep the icon excluded from Apache-2.0. The manifest license field describes
  the reusable implementation and does not override `assets/README.md`.
- External uploads, GitHub releases, workspace changes, and ChatGPT publication
  require explicit user approval.

## Change workflow

1. Inspect the working tree and preserve unrelated user work.
2. Make the smallest change needed in the repository source.
3. When identity, display metadata, or version changes, update both manifests.
4. Keep `README.md` instructions aligned with actual script behavior.
5. Run the focused checks below with synthetic data.
6. Rebuild and inspect the neutral template archive after any source change.
7. Report host behavior separately from local package verification. A valid ZIP
   does not prove that ChatGPT or SVGator authorization works.

## Verification

Preferred:

```sh
nix flake check
```

Focused fallback when Nix is unavailable:

```sh
bash -n scripts/prepare-chatgpt-plugin.sh
shellcheck scripts/prepare-chatgpt-plugin.sh
./scripts/prepare-chatgpt-plugin.sh \
  asdk_app_Test123 \
  /tmp/cfmoon-svgator-chatgpt-test.zip
unzip -t /tmp/cfmoon-svgator-chatgpt-test.zip
```

Inspect archive paths without printing `.app.json`. Confirm there are exactly
eight files and no MCP manifest, README, license file, script, or credential
material.

## Release discipline

- Follow semantic versioning and keep both manifests on the same version.
- Keep the Apache-2.0 `LICENSE`, the separate `assets/README.md` notice, and the
  manifest metadata intact.
- Build the neutral release archive outside the repository directory so the
  archive cannot include itself.
- Include both `LICENSE` and `assets/README.md` in the neutral repository
  template archive; they are excluded only from the personalized upload ZIP.
- Record the release archive's SHA-256 checksum.
- Never reuse a successful host test as evidence for a later release; rerun the
  synthetic package check and ask the tester to verify ChatGPT separately.
