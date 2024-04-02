{ lib, config, pkgs, ... }:

let cfg = config.cookie.networkd;

in with lib; {
  options.cookie.networkd = {
    enable = mkEnableOption "Enables systemd-networkd tweaks";
  };

  config = mkMerge [
    { cookie.networkd.enable = mkDefault config.systemd.network.enable; }
    (mkIf cfg.enable {
      # The notion of "online" is a broken concept
      # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
      # https://github.com/nix-community/srvos/blob/e5a5f15acaff9daa69e7ef5596f6985ec695685f/nixos/common/networking.nix#L14
      systemd.network.wait-online.enable = false;
    })
  ];
}
