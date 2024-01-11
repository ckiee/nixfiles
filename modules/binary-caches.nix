{ config, lib, pkgs, ... }:

let cfg = config.cookie.binary-caches;
in with lib; {
  options.cookie.binary-caches = {
    enable = mkEnableOption "Enables additional binary caches";
  };

  config.nix.settings = mkIf cfg.enable {
    substituters = [
      # "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      # "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
}
