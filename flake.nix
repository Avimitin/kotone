{
  description = "Company financial ledger using Beancount";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              beancount
              fava
              xlsx2csv
            ];
          };

          checks.default = pkgs.runCommand "check-format" { nativeBuildInputs = [ pkgs.beancount ]; } ''
            bean-check ${./main.beancount}
          '';
        };
    };
}
