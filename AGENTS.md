# AGENTS.md

This file contains project guidance for AI coding agents (Codex and others).
It is intentionally **general** and should remain valid even as files move or the repo structure changes.

---

## Working agreements (always follow)

### 1) Operate safely
- Do **not** delete data, drop tables, or remove features unless the user explicitly asks.
- Avoid breaking changes by default; prefer additive, backwards-compatible changes.
- Never commit secrets. Do not paste private keys/tokens into code, docs, issues, or logs.

### 2) Be deterministic and minimal
- Make the smallest change that fixes the bug or implements the request.
- Preserve existing conventions (naming, structure, patterns) unless improving them is part of the request.
- Prefer refactors only when they clearly reduce risk, simplify logic, or unblock correctness.

### 3) Validate before finishing
- Always run the most relevant local checks (typecheck, lint, tests, build) and fix failures you introduced.
- If you cannot run commands in the environment, explain what you would run and why.

### 4) Communicate clearly
When you propose changes, include:
- What you changed and why
- What commands you ran (or would run) and expected output
- Any migration steps, env vars, or manual steps required
- A list of **only the updated files** (paths + brief purpose)

---

## Instruction precedence (for agents)
- User instructions in chat override everything.
- The **closest** applicable instructions file in the directory tree should take precedence.
- If both an `AGENTS.md` and `AGENTS.override.md` exist, the override should be treated as higher priority.

---

## Repo discovery (do this first)
Before editing:
1) Identify the package manager and workspace layout:
   - Prefer lockfile detection:
     - `pnpm-lock.yaml` → pnpm
     - `yarn.lock` → yarn
     - `package-lock.json` → npm
2) Locate the primary entry points:
   - Look for `package.json` scripts and the root build pipeline.
   - Find where the frontend, backend/functions, and database live (if present).
3) Read the closest README/docs for the area you will modify.

---

## Standard quality gates (choose what applies)
Use existing scripts first (from `package.json`). If unknown, typical commands are:

### JavaScript / TypeScript repos
- Install: `<pm> install`
- Typecheck: `<pm> run typecheck` (or `tsc -b` if configured)
- Lint: `<pm> run lint`
- Tests: `<pm> test`
- Build: `<pm> run build`

### Monorepos
- Prefer workspace-aware commands (examples):
  - `pnpm -w run build`
  - `pnpm -C <dir> run build` (only if you verified the directory is a real package)
- Don’t assume folder names; discover packages via workspace config and scripts.

---

## Coding standards (general)
### TypeScript
- Keep strictness: avoid `any`; narrow `unknown`; handle `undefined` safely.
- Prefer small helper functions for repeated narrowing/guards.
- Prefer explicit return types for exported functions in shared modules.

### React (if present)
- Keep components pure and predictable.
- Avoid side effects during render; use effects/hooks appropriately.
- Keep loading/error states explicit.

### Backend (if present)
- Validate inputs; handle errors consistently.
- Avoid leaking internal errors to clients; return safe messages with traceable codes/logs.

---

## Database & migrations (if the repo has a DB layer)
- Prefer migrations over ad-hoc edits.
- Make schema changes additive when possible (new columns/tables, non-breaking defaults).
- For security:
  - Use least privilege.
  - Enable and maintain row-level security (RLS) if the stack uses it.
  - Ensure functions are safe: set an explicit `search_path` and grant only required roles.
- If a change affects API clients, keep compatibility or provide a clear transition plan.

---

## Serverless / Functions (if present)
- Prefer secure defaults (JWT verification, auth checks, input validation).
- Keep deployment constraints in mind (cold starts, timeouts, region latency).
- If you must change authentication behavior, explain the risk and the mitigation.

---

## CI/build stability
- Assume CI runs on Linux with a clean environment.
- Avoid relying on globally installed tools; prefer repo scripts and local dev dependencies.
- Fix the root cause of type/build errors (don’t silence them with broad casts or disabling rules).

---

## Deliverable format (what to output)
When you finish a task:
1) Provide a short summary of the fix/feature.
2) Provide reproduction steps (before/after) when applicable.
3) Provide commands executed (or recommended).
4) List **only updated files** with short descriptions.
5) If you added/changed migrations, include the migration filename(s) and apply order.

---

## Defaults for ambiguity
If requirements are unclear:
- Prefer correctness and security over convenience.
- Prefer compatibility over large redesigns.
- Ask targeted questions only if the ambiguity blocks safe progress; otherwise pick the safest reasonable default and document it.
