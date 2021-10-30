{ pkgs ? ((import (import ../nix/sources.nix).nixpkgs) { }), ... }:

with pkgs;

let sources = import ../nix/sources.nix;
in {
  comicfury-discord-webhook = import sources.comicfury-discord-webhook;
  owo-bot = import sources.owo-bot;
  ffg-bot = import sources.ffg-bot;
  sysyelper = import sources.sysyelper;
  anonvote-bot = callPackage sources.anonvote-bot { };
  iscool = callPackage sources.iscool { };
  ronthecookieme = callPackage ./ronthecookieme { };
  ckiesite = callPackage ./ckiesite { };
}
