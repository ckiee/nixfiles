{ pkgs ? import <nixpkgs>, ... }:

{
  ronthecookieme = pkgs.callPackage ./ronthecookieme { };
}
