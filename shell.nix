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
    (bpkg)
    # (coredns.overrideAttrs (oldAttrs: {
    #   runVend = true;
    #   patches = [ ./ext/coredns-ads-plugin.patch ];
    #   # preConfigurePhases = "scaryPhase";
    #   # scaryPhase = "go get github.com/c-mueller/ads";
    # }))
  ];

  shellHook = ''
    export COOKIE_HOSTNAME=$(${pkgs.hostname}/bin/hostname)
    export COOKIE_NIXFILES_PATH=$(pwd)
  '';
}
