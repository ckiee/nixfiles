{ pkgs ? import <nixpkgs> {} }:

with pkgs;

mkShell {
  buildInputs = [
    niv
    morph
    nix-prefetch-scripts
  ];
}
