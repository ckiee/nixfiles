{ config, lib, pkgs, ... }:

let cfg = config.cookie.binaryCaches;
in with lib; {
  options.cookie.binaryCaches = {
    enable = mkEnableOption "Enables additional binary caches";
  };

  config.nix = mkIf cfg.enable {
    binaryCaches = [
      "https://cache.tailnet.ckie.dev"
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    binaryCachePublicKeys = [
      "cache.tailnet.ckie.dev:Ng8W2u5lGtakekcMxEy7vaw99IwgDaK8ensVZQfZgUQ="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
