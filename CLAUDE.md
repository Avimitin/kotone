# Kotone - Personal Beancount Ledger

This is a personal financial ledger project using [Beancount](https://beancount.github.io/docs/), a double-entry plaintext accounting system.

## Project Structure

```
kotone/
├── flake.nix              # Nix flake configuration (flake-parts style)
├── CLAUDE.md              # This file
└── okane/                 # All beancount files
    ├── main.beancount     # Root file - includes buckets.beancount and year-level main.beancount
    ├── buckets.beancount  # Account definitions (Assets, Liabilities, Income, Expenses, Equity)
    └── YYYY/              # Year directories
        ├── main.beancount # Includes all monthly files for the year
        └── MM.beancount   # Monthly transaction files (e.g., 2026/03.beancount)
```

### File Organization Rules

1. **main.beancount**: The root file must only contain `include` directives. Never add transactions here.
2. **buckets.beancount**: Define all five account types here using `open` directives.
3. **Monthly files**: Transactions go in `okane/YYYY/MM.beancount` based on the transaction date.
   - Example: A transaction on 2026-03-18 → `okane/2026/03.beancount`
4. **Include Hierarchy**:
   - Root `okane/main.beancount` includes `buckets.beancount` and year-level `YYYY/main.beancount` files
   - Each year's `YYYY/main.beancount` includes monthly `MM.beancount` files
   - All include paths are relative to the file's directory
5. **No Account Hallucination**: NEVER use an account in a transaction that has not been explicitly declared via an `open` directive in `buckets.beancount`. If a new account is needed, you must add the `open` directive to `buckets.beancount` first.

## Beancount Knowledge

### Five Account Types (Buckets)

Beancount uses five fundamental account types following double-entry accounting:

| Type | Prefix | Description |
|------|--------|-------------|
| **Assets** | `Assets:` | Things you own (bank accounts, cash, investments) |
| **Liabilities** | `Liabilities:` | Debts and obligations (credit cards, loans) |
| **Income** | `Income:` | Money received (salary, dividends, interest) |
| **Expenses** | `Expenses:` | Money spent (food, rent, utilities) |
| **Equity** | `Equity:` | Net worth, opening balances |

### Basic Syntax

```beancount
; Account declaration (goes in buckets.beancount)
YYYY-MM-DD open AccountName
YYYY-MM-DD close AccountName

; Commodity/currency declaration
YYYY-MM-DD commodity CURRENCY
  name: "Currency Name"

; Transaction
YYYY-MM-DD * "Payee" "Narration"
  Account:Debit    AMOUNT CURRENCY
  Account:Credit   -AMOUNT CURRENCY

; Balance assertion
YYYY-MM-DD balance Account  AMOUNT CURRENCY

; Pad (fill gaps in balance assertions)
YYYY-MM-DD pad Account:Target Account:Source
```

### Transaction Examples

```beancount
; Simple expense
2026-03-18 * "Grocery Store" "Weekly groceries"
  Expenses:Food:Groceries    50.00 CNY
  Assets:Bank:Checking      ; Amount left blank intentionally to auto-balance

; Split transaction
2026-03-18 * "Shopping Mall" "Multiple items"
  Expenses:Clothing          30.00 CNY
  Expenses:Electronics      100.00 CNY
  Liabilities:CreditCard   ; Amount left blank intentionally to auto-balance

; Income
2026-03-18 * "Employer" "March salary"
  Assets:Bank:Checking    3000.00 CNY
  Income:Salary          ; Amount left blank intentionally to auto-balance
```

### Key Principles

1. **Double-Entry**: Every transaction must balance. Sum of all postings must equal zero.
2. **Explicit Dates**: All entries require a date in `YYYY-MM-DD` format.
3. **Imbalance Detection**: Beancount will error if transactions don't balance.
4. **Currency Case**: Currencies are typically uppercase (CNY, USD, EUR).
5. **Default Currency**: If no currency is specified in input, assume CNY (Chinese Yuan).
6. **Strict Capitalization**: Every segment of an account name MUST start with a capital letter (e.g., `Assets:Bank:Checking`, NOT `Assets:bank:checking`).
7. **Auto-Balancing**: To prevent arithmetic errors, leave the amount and currency blank on the final posting of a transaction. Beancount will automatically calculate the difference.
8. **Indentation**: All transaction postings must be indented with at least two spaces. Align all amounts vertically for readability.

## Nix Development Environment

This project uses [flake-parts](https://flake.parts/) for modular Nix configuration.

### Available Commands

```bash
# Enter development shell with beancount
nix develop

# Run beancount checks
nix flake check

# Build (if applicable)
nix build
```

### Flake Structure Convention

When modifying `flake.nix`, maintain the flake-parts pattern:

```nix
{
  inputs = { ... };
  outputs = inputs@{ ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      
      perSystem = { pkgs, ... }: {
        devShells.default = ...;
        packages = ...;
        checks = ...;
      };
    };
}
```

### Adding Dependencies

Add new tools to `devShells.default.packages` in `flake.nix`:

```nix
devShells.default = pkgs.mkShell {
  packages = with pkgs; [
    beancount
    # Add more tools here
  ];
};
```

## Skills

This project includes custom skills for common tasks:

### Add Transaction

**Skill file**: `.claude/skills/transaction.md`

Use this skill to add new transactions from natural language input. The skill will:
- Parse your description into beancount format
- Ask for missing information (date, payee, accounts, amounts)
- Write to the correct monthly file
- Validate with `bean-check`

**Usage examples**:
- "Add transaction: bought coffee for $5"
- "Record: received salary $3000 to checking"
- "Paid rent $1200 from checking on March 1st"

## Validation

Always run `bean-check` after modifying beancount files:

```bash
nix develop -c bean-check okane/main.beancount
```

Or use the flake check:

```bash
nix flake check
```
