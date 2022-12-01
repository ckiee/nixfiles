{ nodes, lib, config, pkgs, ... }:

let
  cfg = config.cookie.tailnet-certs;
  hostname = config.networking.hostName;
in with lib;
with builtins; {
  options.cookie.tailnet-certs = {
    enableServer =
      mkEnableOption "Enables sharing of the *.tailnet TLS certificate";
    client = mkOption {
      type = types.submodule {
        options = {
          enable =
            mkEnableOption "Enables usage of the *.tailnet TLS certificate";
          hosts = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "nginx vhosts to configure";
          };
          forward = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description =
              "nginx vhosts to publicly expose by forwarding through the enableServer host";
          };
        };
      };
      default = { enable = false; };
      description = "client options";
    };
    host = mkOption {
      type = types.str;
      default = "tailnet.ckie.dev";
      description = "Full host to share";
    };
    serveHost = mkOption {
      type = types.str;
      default = "certs.tailnet.ckie.dev";
      description = "Host to serve the certificates on";
    };
  };

  imports = [ ./client.nix ./server.nix ];
  config = {
    cookie.services.coredns.extraHosts = ''
      ${
        (head (attrValues
          (filterAttrs (_: host: host.config.cookie.tailnet-certs.enableServer)
            nodes))).config.cookie.state.tailscaleIp
      } certs.tailnet.ckie.dev
      ${concatStringsSep "\n" (mapAttrsToList (name: h:
        concatMapStringsSep "\n" (vhost:
          "${
            h.config.cookie.state.tailscaleIp or (throw
              "Missing tailscaleIp for ${name}")
          } ${vhost}") h.config.cookie.tailnet-certs.client.hosts) nodes)}
    '';
  };
}
