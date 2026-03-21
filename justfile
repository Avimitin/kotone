default:
    just --list

view:
    nix develop -c fava okane/main.beancount

owe:
    nix develop -c bean-query okane/main.beancount "select sum(position) where root(account)='Liabilities'"

owe-by-account:
    nix develop -c bean-query okane/main.beancount "select account, sum(position) where root(account)='Liabilities' group by account order by account"

left:
    nix develop -c bean-query okane/main.beancount "select sum(position) where root(account)='Assets'"

report:
    @echo "How much I owe:"
    @nix develop -c bean-query okane/main.beancount "select sum(position) where root(account)='Liabilities'"
    @echo ""
    @echo "Liabilities by account:"
    @nix develop -c bean-query okane/main.beancount "select account, sum(position) where root(account)='Liabilities' group by account order by account"
    @echo ""
    @echo "How much I have left (total assets):"
    @nix develop -c bean-query okane/main.beancount "select sum(position) where root(account)='Assets'"
