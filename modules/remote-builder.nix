{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.remote-builder;
  nix-store = ''
    NIX_SSHOPTS="-oStrictHostKeyChecking=no -oIdentityFile=/home/ckie/.ssh/id_ed25519" ${config.nix.package}/bin/nix-store'';
  wrapper = pkgs.writeScript "cookie-remote-build" "sudo ${nix-store} $@";
in with lib; {
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
        openssh.authorizedKeys.keys = [
          # see https://github.com/ckiee/nix/blob/d40828224ae0d47acc70e5431dd2f42775085ebe/src/libstore/legacy-ssh-store.cc#L75-L76
          ''
            no-port-forwarding,no-X11-forwarding,no-pty,restrict,command="sudo ${wrapper} --serve --write" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3uTwzSSMAPg84fwbNp2cq9+BdLFeA1VzDGth4zCAbz https://ckie.dev''
        ];
        group = "remote-builder";
      };
      users.groups.remote-builder = { };
    })

    (mkIf (cfg.role == "user") {
      nix.buildMachines = [{
        hostName = "remote-builder@pansear";
        system = "x86_64-linux";
        supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
        mandatoryFeatures = [ ];
      }];
      nix.distributedBuilds = true;
      nix.extraOptions = ''
        # useful when the builder has a faster internet connection than yours
        builders-use-substitutes = true
      '';
    })
  ];
}
