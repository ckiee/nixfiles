{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.garage;

in with lib; {
  options.cookie.services.garage = {
    enable = mkEnableOption "garage on chonk";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 3900 ];
    systemd.tmpfiles.rules = [ "d  /mnt/chonk/garage 0700 garage root -" ];
    systemd.services.garage.serviceConfig.DynamicUser = false;
    systemd.services.garage.bindsTo = [ "mnt-chonk.mount" ];
    users.users.garage = {
      isSystemUser = true;
      group = "garage";
    };
    users.groups.garage = { };

    services.garage = {
      enable = true;
      package = pkgs.garage_1_x;
      environmentFile = config.cookie.secrets.garage-env.dest;
      settings = {
        replication_factor = 1;

        data_dir = "/mnt/chonk/garage";
        db_engine = "sqlite";

        rpc_bind_addr = "[::]:3901";
        # rpc_secret = .env

        s3_api = {
          api_bind_addr = "[::]:3900";
          s3_region = "tlv";
        };
      };
    };

    cookie.secrets.garage-env = rec { source = "./secrets/garage.env"; };
  };
}
