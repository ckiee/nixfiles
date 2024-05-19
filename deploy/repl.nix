let
  sources = import ../nix/sources.nix;
  pkgs = import sources.nixpkgs { };
in pkgs.lib // rec {
  inherit pkgs sources;
  eval = import "${sources.morph}/data/eval-machines.nix" {
    networkExpr = ../deploy/morph.nix;
  };
  nodes = eval.nodes;
}
