{ lib, config, pkgs, ... }:

let cfg = config.cookie.steam;

in with lib; {
  options.cookie.steam = { enable = mkEnableOption "Enables steam"; };

  config = mkIf cfg.enable {
    # TODO Make nixpkgs PR
    # This is for SteamVR
    nixpkgs.overlays = [
      (self: super: {
        steam = super.steam.override { extraPkgs = spkgs: with spkgs; [ gksu ]; };
      })
    ];
    programs.steam.enable = true;
    environment.systemPackages = with pkgs; [ steam-run-native ];

    programs.gamemode = {
      enable = true;
      enableRenice = true;
    };
  };
}
