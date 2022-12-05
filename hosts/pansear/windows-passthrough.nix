{ config, lib, pkgs, ... }:

{
  users.users.win = {
    isNormalUser = true;
    # empty password:
    hashedPassword =
      "$6$HpJwJOJx9KR$4tR8WgBq4m8GdSxrK6920WxnklprO4hQfAJa2xNKdfoG9bbPBG3rEEx292Dat/RNe1Bjnu..O860JJhpN8B2R.";
  };

  services.xserver = {
    enable = true;
    displayManager.session = [({
      manage = "desktop";
      name = "windows";
      start =
        "${pkgs.freerdp}/bin/xfreerdp /u:Mik /p:mik /v:192.168.122.2 /cert:ignore +auto-reconnect /auto-reconnect-max-retries:0 +clipboard /f /dynamic-resolution -toggle-fullscreen /sec:tls";
    })];
    displayManager = {
      hiddenUsers = [ "ckie" ];
      autoLogin = {
        enable = true;
        user = "win";
      };
    };
    videoDrivers = [ "nvidia" ];
  };
}
