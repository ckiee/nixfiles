{ pkgs, ... }:

{
  services.redshift = {
    enable = true;
    tray = true;
    provider = "manual";
    latitude = "32.15";
    longitude = "34.8";
  };
}
