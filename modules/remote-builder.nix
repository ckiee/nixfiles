{ nodes, lib, config, pkgs, ... }:

with builtins;
with lib;

let
  cfg = config.cookie.remote-builder;
  nix-store = "${config.nix.package}/bin/nix-store --serve --write";
  wrapper = pkgs.writeScript "cookie-remote-build" "sudo ${nix-store} $@";
in {
  options.cookie.remote-builder = {
    role = mkOption {
      type = types.nullOr (types.enum [ "builder" "user" ]);
      default = null;
      description = "The purpose of this machine";
    };
  };

  config = mkMerge [
    (mkIf (cfg.role == "builder") {
      security.sudo.extraRules = [{
        users = [ "remote-builder" ];
        runAs = "root";
        commands = singleton {
          command = "${wrapper}";
          options = [ "NOPASSWD" ];
        };
      }];
      users.users.remote-builder = {
        isSystemUser = true;
        useDefaultShell = true;
        openssh.authorizedKeys.keys = map (key:
          ''
            no-port-forwarding,no-X11-forwarding,no-pty,restrict,command="sudo ${wrapper}" ${key}'')
          [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINOXurLSbdSEr5mJH0dmLjqbaSAl2amq/Lh5tuNI90Q3 buildfarm"
          ];
        group = "remote-builder";
      };
      users.groups.remote-builder = { };
    })

    (mkIf (cfg.role == "user") {
      nix.distributedBuilds = true;
      nix.extraOptions = ''
        # useful when the builder has a faster internet connection than yours
        builders-use-substitutes = true
      '';
      nix.buildMachines = [{
        hostName = "remote-builder@pansear";
        system = "x86_64-linux";
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
        maxJobs = 16;
      }];

      # Nix needs to be given SSH details! Naturally, we encrypt the key

      cookie.secrets.ssh-buildfarm-key = {
        source = "./secrets/ssh_buildfarm_key";
        permissions = "0400";
        wantedBy = "nix-daemon.service";
      };
      systemd.services.nix-daemon.environment.NIX_SSHOPTS = let
        knownHosts = pkgs.writeText "known-hosts" ''
          ${concatStringsSep "\n" (mapAttrsToList (name: node:
            "${name} ${node.config.cookie.state.sshPubkey}") (filterAttrs (_: n: n.config.cookie.state.sshPubkey != null) nodes))}
          # external hosts here:
        '';
      in "-oIdentityFile=${config.cookie.secrets.ssh-buildfarm-key.dest} -oUserKnownHostsFile=${knownHosts}";
    })
  ];
}
