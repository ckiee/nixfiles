{ config, pkgs, ... }: {
  imports = [ ../.. ];

  home-manager.users.ckie = { ... }: { cookie = { st.enable = true; }; };

  #### Stub ####
  networking.hostName = "hmporter";
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
    fsType = "ext4";
  };
}
