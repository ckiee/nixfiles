{ pkgs ? import <nixpkgs> { } }:

let
  bpkg = pkgs.writeScriptBin "bpkg" ''
    COOKIE_TOPLEVEL=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    nix-build "$COOKIE_TOPLEVEL/pkgs" -A "$@"
  '';
in pkgs.mkShell {
  buildInputs = with pkgs; [
    niv
    morph
    nix-prefetch-scripts
    nix-prefetch-github
    bpkg
  ];
}
