{ lib, config, pkgs, ... }:

let cfg = config.cookie.ledc;

in with lib; {
  options.cookie.ledc = {
    # XXX: Enable is also read in i3 auxapps for auto-start.
    enable = mkEnableOption
      "Enables ledc, software to talk to the desk LED strip firmware at home";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ cookie.ledc ];
  };
}
