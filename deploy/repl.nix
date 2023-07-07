rec {
  sources = import ../nix/sources.nix;
  eval = import "${sources.morph}/data/eval-machines.nix" {
    networkExpr = ../deploy/morph.nix;
  };
  pkgs = import sources.nixpkgs { };
  nodes = eval.nodes;
}
