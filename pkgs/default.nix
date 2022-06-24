{ pkgs ? ((import (import ../nix/sources.nix).nixpkgs) { }), ... }:

with pkgs;

let sources = import ../nix/sources.nix;
in {
  comicfury-discord-webhook = import sources.comicfury-discord-webhook;
  owo-bot = import sources.owo-bot;
  ffg-bot = import sources.ffg-bot;
  daiko = callPackage sources.daiko { };
  mcid = callPackage sources.mcid { };
  alvr-bot = callPackage sources.alvr-bot { };
  anonvote-bot = callPackage sources.anonvote-bot { };
  ckiesite = import sources.ckiesite;
}
