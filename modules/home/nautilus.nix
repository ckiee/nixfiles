{ lib, config, pkgs, nixosConfig, ... }:

let cfg = config.cookie.nautilus;
in with lib; {
  options.cookie.nautilus = {
    enable = mkEnableOption "Enables forcing of some Nautilus preferences";
  };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = nixosConfig.programs.dconf.enable;
      message = "dconf must be enabled in the system configuration";
    }];
    dconf.settings."org/gnome/nautilus/preferences" = {
      default-sort-in-reverse-order = true;
      default-sort-order = "mtime";
    };

    # ugh.. really need to write that nautilus-with-extensions thing and send it upstream
    # as per: https://github.com/NixOS/nixpkgs/issues/126074#issuecomment-1025579974
    home.sessionVariables.NAUTILUS_4_EXTENSION_DIR = "${config.home.homeDirectory}/.nix-profile/lib/nautilus/extensions-4";
    home.packages = with pkgs; [ nautilus nautilus-open-any-terminal ];
    # ..it still doesn't work. TODO.
  };
}
