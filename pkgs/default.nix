let sources = import ../nix/sources.nix;
in { pkgs ? (import sources.nixpkgs) { }, ... }:

with pkgs; {
  comicfury-discord-webhook = import sources.comicfury-discord-webhook;
  owo-bot = import sources.owo-bot;
  ffg-bot = import sources.ffg-bot;
  daiko = callPackage sources.daiko { };
  mcid = callPackage sources.mcid { };
  alvr-bot = callPackage sources.alvr-bot { };
  anonvote-bot = callPackage sources.anonvote-bot { };
  ckiesite = import sources.ckiesite;
  ledc = ((import sources.desk-fcobs).overrideInputs {
    nixpkgs = pkgs.path;
  }).default;
  tonsi-li = sources."tonsi.li";
  bandcamp-dl = callPackage ./bandcamp-dl { };
  actual-server = callPackage ./actual-server { };
  listenwithmed = ((import sources.listenwithmed).overrideInputs {
    nixpkgs = pkgs.path;
  }).default;
  transqsh = ((import sources.transqsh).overrideInputs {
    nixpkgs = pkgs.path;
  }).default;
  raspberrypi-utils = callPackage "${sources.nixos-raspberrypi}/pkgs/raspberrypi/raspberrypi-utils.nix" {};
}
