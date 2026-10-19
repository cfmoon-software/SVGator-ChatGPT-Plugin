---
name: svgator-animate
description: "Create, inspect, refine, and export editable SVGator animations, including logo reveals, motion graphics, loaders, and reusable templates. Use with an SVGator project, SVG artwork, a reference, or a written animation brief."
---

# Animate with SVGator

## Establish access and direction

Confirm that SVGator's tools are exposed and account access works. Follow [SVGator setup](../svgator-setup/SKILL.md) if connection or authentication is unresolved. Do not simulate an MCP call or claim a project exists without a successful server result.

Infer the placement, artwork, and motion direction from the request. Ask only for inputs that materially affect the result; choose and state reasonable timing and canvas defaults otherwise. Use a supplied SVG or project to preserve its identity. For missing artwork, author suitable shapes and text; treat raster references as references unless the available workflow supports their import. Rebuild editable vector parts when individual shape animation is needed. Never present an embedded bitmap as independently editable vector geometry.

Use brand assets and supplied geometry faithfully. For CFMoon work, retain the CFMoon spelling and the user's provided mark. Apply geometric energy effects or Hina styling only when the request calls for them.

## Read the server's live authoring guidance

Use the connected server's initialization instructions, motion-design prompt, and relevant resources when the host exposes them. Discover available resource handles before reading them. Prefer SVGator's live craft guidance over copying its entire library into this plugin. If resource access is unavailable, consult [the official resource guide](https://github.com/SVGator/mcp/blob/main/skill-and-resources.md) and use supported tools.

Consult the exposed authoring-reference tool, such as `describe_shape`, for the actual element, animation, and export contracts before constructing project data. Never invent schemas from remembered examples.

## Build or revise incrementally

For an existing project, inspect its summary and structure, locate the target, then read only the affected elements or properties. Distinguish static properties from values controlled by keyframes. Change the animated channel when animation overrides a static value. Reuse server-returned element IDs and inserted-item paths.

Preserve unrelated layers, editable text, and project settings. Duplicate a source template before editing it. Prefer incremental edits for refinements; use whole-document creation for a genuinely new project. Avoid replacing an existing document wholesale unless the requested change requires it and its scope is clear.

Plan a readable sequence with a dominant motion, purposeful easing, and a settled finish or seamless loop. Coordinate supporting effects with the main action. Adapt motion amplitude and playback to the intended placement. Keep replaceable logo, headline, and image elements clearly named when building a reusable template.

After each meaningful change, use the server's validation result and available preview to inspect the affected result. Check clipping, stacking, typography, pacing, easing, final state, and loop continuity. Correct failures before continuing. Do not claim to have watched playback when only static evidence is available.

## Deliver the editable result

Use current export schemas and the account's actual plan capabilities for the requested formats. Preserve transparency when requested. Check asynchronous render status before claiming a video or GIF is ready; retrieve a fresh download link when a signed link expires.

Return the server's editor URL, requested exports, and a short description of the motion. Distinguish saved source, visual review, and tested playback. Report export restrictions or unverified behavior plainly.

Primary references:
- [SVGator tools](https://github.com/SVGator/mcp/blob/main/tools.md)
- [Project editing](https://github.com/SVGator/mcp/blob/main/editing.md)
- [Exporting](https://github.com/SVGator/mcp/blob/main/exporting.md)
