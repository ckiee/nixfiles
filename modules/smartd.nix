{ config, pkgs, ... }:

{
  services.smartd = {
    enable = true;
    notifications.x11.enable = true;
  };
}
