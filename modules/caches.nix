{ config, lib, pkgs, ... }:

let cfg = config.cookie.binaryCaches;
in with lib; {
  options.cookie.binaryCaches = {
    enable = mkEnableOption "Enables additional binary caches";
  };

  nix = mkIf cfg.enable {
    binaryCaches =
      [ "https://nix-community.cachix.org" "https://cache.nixos.org/" ];
    binaryCachePublicKeys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
