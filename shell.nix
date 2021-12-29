{ ... }:

with builtins;

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };

  cBin = pkgs.writeScriptBin "c" (readFile ./bin/c);

  morph = import sources.morph { inherit pkgs; };
in pkgs.mkShell {
  NIX_PATH = "nixpkgs=${pkgs.path}";

  buildInputs = with pkgs; [
    niv
    morph
    nix-prefetch-scripts
    nix-prefetch-github
    (nixos-generators.override { nix = nixUnstable; })
    cBin
  ];
}
