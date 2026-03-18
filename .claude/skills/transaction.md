# Add Transaction Skill

Add a new transaction to the beancount ledger from natural language input.

## Instructions

You are a transaction entry assistant. Parse the user's natural language input and convert it to a valid beancount transaction.

### Required Information

Every transaction must have:
1. **Date**: Format YYYY-MM-DD (default to today if not specified)
2. **Payee**: Who received/gave the money
3. **Narration**: Description of the transaction (optional but recommended)
4. **Postings**: At least 2 account postings with amounts that sum to zero
5. **Currency**: Default to CNY if not specified in the input

### Process

1. **Parse Input**: Extract as much information as possible from the user's input:
   - Date (look for date patterns or relative terms like "yesterday", "last week")
   - Payee (store name, person, company)
   - Amount and currency (default to CNY if not specified)
   - Category/expense type hints

2. **Identify Missing Information**: Determine what's missing:
   - If date is missing, use today's date
   - If payee is unclear, ask
   - If accounts are unclear, ask which account to use
   - If amounts don't balance, ask for clarification

3. **Ask Clarifying Questions**: Use the Question tool to gather missing information. Ask one question at a time or batch related questions.

4. **Generate Transaction**: Create valid beancount syntax:
   ```beancount
   YYYY-MM-DD * "Payee" "Narration"
     Account:One      AMOUNT CURRENCY
     Account:Two     -AMOUNT CURRENCY
   ```

5. **Write to File**: 
   - Determine the correct file: `okane/YYYY/MM.beancount` based on transaction date
   - Create the year directory if it doesn't exist
   - Create the month file if it doesn't exist
   - Append the transaction to the file
   - Ensure `okane/main.beancount` includes this file

6. **Validate**: Run `bean-check` to verify the transaction is valid.

### Account Reference

Common account patterns (refer to `okane/buckets.beancount` for actual accounts):

| Type | Examples |
|------|----------|
| Assets | `Assets:Bank:Checking`, `Assets:Cash`, `Assets:Bank:Savings` |
| Liabilities | `Liabilities:CreditCard:Visa`, `Liabilities:CreditCard:Mastercard` |
| Income | `Income:Salary`, `Income:Dividends`, `Income:Interest` |
| Expenses | `Expenses:Food:Groceries`, `Expenses:Transport:Subway`, `Expenses:Housing:Rent` |
| Equity | `Equity:Opening-Balances` |

**Note**: Currency defaults to CNY (Chinese Yuan) if not specified.

### Example Interactions

**User**: "Bought groceries for 50 yuan at the supermarket"
**Assistant**: 
- Date: today
- Payee: "Supermarket"
- Narration: "Groceries" (inferred)
- Amount: 50 CNY
- Need to ask: Which account was used? (cash, checking, credit card?)

**User**: "Paid rent 3000 from checking on March 1st"
**Assistant**:
- Date: 2026-03-01
- Payee: "Landlord" (need to confirm or ask)
- Narration: "Rent"
- Expenses:Housing:Rent 3000 CNY
- Assets:Bank:Checking -3000 CNY
- Ready to write (confirm with user)

### Error Handling

- If `bean-check` fails, show the error and offer to fix the transaction
- If the target file doesn't exist, create it
- If accounts don't exist in buckets.beancount, offer to add them

## Usage

To use this skill, the user can say things like:
- "Add transaction: bought coffee for $5"
- "Record: received salary $3000 to checking"
- "New entry: paid electric bill $85 from credit card"
- Or simply describe the transaction naturally
