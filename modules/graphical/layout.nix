{ config, pkgs, ... }: {
  services.xserver.displayManager.sessionCommands =
    "sh -c '${pkgs.xorg.xmodmap}/bin/xmodmap /home/ron/dots/xorg/.local/share/layouts/caps*'";

  services.xserver.layout = "us,il";
  services.xserver.xkbOptions = "grp:win_space_toggle";
}
