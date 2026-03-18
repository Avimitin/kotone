default:
    just --list

view:
    nix develop -c fava okane/main.beancount
