{ util, config, lib, pkgs, ... }:

{
  boot.kernel.sysctl."net.ipv4.ip_forward" = true;
  systemd.services.net-offload = {
    description = "Watch for suitable devices to use to reroute the network";
    wantedBy = [ "multi-user.target" ];
    serviceConfig.ExecStart = util.mkRequiresScript ./net-offload.sh;
    environment = {
      MAIN_IFACE = "eth0";
      SSH_OPTS = "-i ${config.cookie.secrets.darcher-ssh-rsa.dest} -oStrictHostKeyChecking=no";
    };
  };

  # pubkey:
  # ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDD23Iy0QX9ky9b2tUoKecmasboLDLb0vm4XtYjlMoLute9WU6CHIFLPZeJ5hC2THIfght7d3/lf6EF6cPjHAmTRJNzEfcV+dOXpbjIEF7dX5CYB4TijDgRqiNUSeQ+flqJbrOwZMlVOhhzE1lgVeINUPXQjUuSs4/rIAYiiQq2Y9lI1rpKC+L2HjEWdjVTJwVYxSrhx5bl+rkiLAjq8s4XQPrzO7AQyPosVOPDgGeBG5A0i5EYtumAZrQEDp34ttnYFJkm/ylDDiOhBgvdoqzVIrsV/DbOT7QvZyjMfUu0t2K6uDaPG3Uzv6WfKUEeqbntuml24UjnmiPld/Lqc3JZy3JXgEnlXGFwXw6Z5IgT0icBgE5l+GZel3F5k7sGJfWnMP0i3h7B3c2q0//XWxPnAaiVIZZ+hH7NdXVh7gacTl5NGPwerD0RlDcCYzNwTEp9F61eOLfb4QQeHc7Pe7YZ8tDNOsfybhPQGckpunbTxOU8Gd2Lump6l62kiGFK1ELCNVFlgKqCHmmktZSD0yS7PQGj3h0jZXeVDCKehrMntw69/J+Z7J8n7iB8t/RBhYMyvHsZBV3kTVD5m4CZpBf3AJLAiSbSW+Hr39RBpOOz06beY4dqK03yeQBuVbEdpP5oUZ/S9iT2VwHqwL5FVX6TvGzXYpV5nSccuAnzAm6TDQ== darcher-ssh-rsa
  cookie.secrets.darcher-ssh-rsa = {
    source = "./secrets/darcher-ssh-rsa";
    permissions = "0400";
    wantedBy = "net-offload.service";
  };
}
