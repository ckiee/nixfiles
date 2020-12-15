{ config, pkgs, ... }:

{
  services.xserver = {
    # deviceSection = ''
    #   Option      "AccelMethod"  "sna"
    #   Option      "TearFree"  "true"
    # '';
    # videoDrivers = [ "intel" ];
    videoDrivers = [ "modsetting" ];
    useGlamor = true;
  };
}
