let
  sources = import ../nix/sources.nix;
  eval = import "${sources.morph}/data/eval-machines.nix" {
    networkExpr = ./morph.nix;
  };
  pkgs = import sources.nixpkgs { };
  inherit (eval) uncheckedNodes nodes;
  inherit (pkgs) lib;
in "${pkgs.writeScriptBin "ckie-hm-port"
nodes.pansear.config.systemd.services.home-manager-ckie.serviceConfig.ExecStart}"
