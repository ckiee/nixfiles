{ ... }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  agenix = import sources.agenix { };
  bpkg = pkgs.writeScriptBin "bpkg" ''
    COOKIE_TOPLEVEL=$(${pkgs.git}/bin/git rev-parse --show-toplevel)
    nix-build "$COOKIE_TOPLEVEL/pkgs" -A "$@"
  '';
  rager = pkgs.writeScriptBin "rager" ''
    set -e
    export COOKIE_RAGER_BUILD=1
    for machine in "$(mo build morph.nix)/"*
      do "$machine"/sw/cookie-rager-encrypt
    done
  '';
  mo = pkgs.writeScriptBin "mo" ''
    COOKIE_TOPLEVEL=$(${pkgs.git}/bin/git rev-parse --show-toplevel) ${pkgs.morph}/bin/morph $@
  '';
in pkgs.mkShell {
  buildInputs = with pkgs; [
    niv
    mo
    nix-prefetch-scripts
    nix-prefetch-github
    bpkg
    agenix.agenix
    rager
  ];
}
