{ lib, config, pkgs, ... }:

let cfg = config.cookie.nvidia-autoswitch;

in with lib; {
  options.cookie.nvidia-autoswitch = {
    enable = mkEnableOption "Enables nvidia-autoswitch";
  };

  config = mkIf cfg.enable {
    systemd.services.nvidia-autoswitch = {
      wantedBy = [ "graphical.target" ];
      path = with pkgs; [ ripgrep ];
      preScript = ''
        if lspci | rg 'NVIDIA Corporation'; then
          /run/current-system/specialisation/nvidia/activate
        fi
      '';
    };
    specialisation.nvidia.configuration = { config, ... }: {
      services.xserver.videoDrivers = ["nvidia"];
    };
  };
}
