{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  buildInputs = [
    niv
    morph
    nix-prefetch-scripts
    # (coredns.overrideAttrs (oldAttrs: {
    #   runVend = true;
    #   patches = [ ./ext/coredns-ads-plugin.patch ];
    #   # preConfigurePhases = "scaryPhase";
    #   # scaryPhase = "go get github.com/c-mueller/ads";
    # }))
  ];

  shellHook = "export COOKIE_HOSTNAME=$(hostname)";
}
