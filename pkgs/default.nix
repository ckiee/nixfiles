{ pkgs ? import <nixpkgs> { }, ... }:
let sources = import ../nix/sources.nix;
in {
  comicfury-discord-webhook = import sources.comicfury-discord-webhook;
  ronthecookieme = pkgs.callPackage ./ronthecookieme { };
}
