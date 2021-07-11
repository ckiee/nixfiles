{ pkgs ? import <nixpkgs> { }, ... }:
let sources = import ../nix/sources.nix;
in {
  comicfury-discord-webhook = import sources.comicfury-discord-webhook;
  owo-bot = import sources.owo-bot;
  ffg-bot = import sources.ffg-bot;
  ronthecookieme = pkgs.callPackage ./ronthecookieme { };
  ckiesite = pkgs.callPackage ./ckiesite { };
}
