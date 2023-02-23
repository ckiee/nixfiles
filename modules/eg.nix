{ lib, config, pkgs, ... }:

let cfg = config.cookie.eg;

in with lib; {
  options.cookie.eg = { enable = mkEnableOption "Enables eg container"; };

  config = mkIf cfg.enable {
    assertions = [{
      assertion = config.networking.hostName == "pansear";
      message = "eg container intended to be run on pansear only (for now)";
    }];

    networking.firewall.allowedTCPPorts = [ 13443 ];
    containers.eg = {
      enableTun = true;
      autoStart = true;
      forwardPorts = [{
        containerPort = 443;
        hostPort = 13443;
        protocol = "tcp";
      }];
      path = "/nix/var/nix/profiles/per-container/eg";
      privateNetwork = true;
    };
  };
}
