# Kotone - Personal Beancount Ledger

Personal finance ledger powered by [Beancount](https://beancount.github.io/docs/).

## Project Layout

```text
kotone/
├── flake.nix
├── CLAUDE.md
└── okane/
    ├── main.beancount
    ├── buckets.beancount
    └── YYYY/
        ├── main.beancount
        └── MM.beancount
```

## Beancount File Rules

1. `okane/main.beancount` contains only `include` lines. Never add transactions there.
2. `okane/buckets.beancount` defines accounts with `open` directives.
3. Transactions go in monthly files: `okane/YYYY/MM.beancount` by transaction date.
4. Include hierarchy:
   - root `okane/main.beancount` includes `buckets.beancount` and each `YYYY/main.beancount`
   - each `YYYY/main.beancount` includes all monthly `MM.beancount` files
   - include paths are relative to the including file
5. Never use undeclared accounts in transactions. If needed, add an `open` first.

## Beancount Essentials

- Five account roots: `Assets`, `Liabilities`, `Income`, `Expenses`, `Equity`.
- Every transaction must balance (double-entry).
- Use `YYYY-MM-DD` dates.
- Default currency is `CNY` if user does not specify one.
- Use uppercase currency codes (for example `CNY`, `USD`).
- Account segment capitalization is strict (`Assets:Bank:CMB:Gold`, not `Assets:bank:cmb:gold`).
- For safer math, leave amount blank on the final posting to auto-balance.
- Indent postings by at least two spaces.

## Privacy Rules

1. Replace real person names with aliases (for example `Friend A`).
2. Replace specific addresses with abstract labels (`Home`, `Apartment`).
3. If user input contains sensitive personal data, warn first and suggest sanitized text.

## Nix Environment

- Enter dev shell: `nix develop`
- Validate ledger quickly: `nix develop -c bean-check okane/main.beancount`
- Run flake checks: `nix flake check`
- Build (if needed): `nix build`

When editing `flake.nix`, keep flake-parts style with `flake-parts.lib.mkFlake` and add tools under `devShells.default.packages`.

## Jujutsu (jj) Workflow

1. Run `jj status` before starting work.
2. Create a new working change only when needed:
   - if current workspace has file changes and they are unrelated to the new prompt, run `jj new`
   - if current working copy has no file changes, start directly without `jj new`
3. Add a description with `jj desc -m "..."`.
4. Only push/update `master` when explicitly asked; do not push temporary bookmarks.
5. Never auto-push or auto-create/move bookmarks.

## Skill

- Transaction helper: `.claude/skills/transaction.md`
  - parses natural language transactions
  - asks for missing info
  - writes to correct monthly file
  - validates with `bean-check`

## Validation Requirement

After any Beancount change, run:

```bash
nix develop -c bean-check okane/main.beancount
```
