{ lib, config, pkgs, ... }:

let cfg = config.cookie.networkmanager;

in with lib; {
  options.cookie.networkmanager = {
    enable = mkEnableOption "Enables NetworkManager tweaks";
  };

  config = mkMerge [
    {
      cookie.networkmanager.enable =
        mkDefault config.networking.networkmanager.enable;
    }
    (mkIf cfg.enable {
      # The notion of "online" is a broken concept
      # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
      # https://github.com/nix-community/srvos/blob/e5a5f15acaff9daa69e7ef5596f6985ec695685f/nixos/common/networking.nix#L14
      systemd.services.NetworkManager-wait-online.enable = false;
    })
  ];
}
