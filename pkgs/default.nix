{ pkgs ? import <nixpkgs> { }, ... }:
let sources = import ../nix/sources.nix;
in {
  comicfury-discord-webhook = import sources.comicfury-discord-webhook;
  owo-bot = import sources.owo-bot;
  ronthecookieme = pkgs.callPackage ./ronthecookieme { };
}
