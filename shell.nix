{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    niv
    morph
    nix-prefetch-scripts
  ];

  shellHook = "export COOKIE_HOSTNAME=$(hostname)";
}
