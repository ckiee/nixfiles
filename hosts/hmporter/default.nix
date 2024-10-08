{ config, pkgs, ... }: {
  imports = [ ../.. ];

  cookie.wireguard.enable = false;
  home-manager.users.ckie = { ... }: {
    cookie = { st.enable = true; };
    home.stateVersion = "23.05";
  };

  #### Stub ####
  networking.hostName = "hmporter";
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };
}
