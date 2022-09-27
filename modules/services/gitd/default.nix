# TODO backups!!
#
{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.gitd;
  cgit = pkgs.cgit-pink.overrideAttrs (orig: {
    patches = # orig.patches ++
      [ ./0001-ui-shared-allow-the-auth-filter-to-display-a-notice.patch ];
  });
  auth = pkgs.callPackage ./auth { };
  # auth = "/tmp/cgito";
in with lib; {
  options.cookie.services.gitd = {
    enable = mkEnableOption "Enables the gitd service";
    host = mkOption {
      type = types.str;
      default = "git.ckie.dev";
      description = "nginx vhost";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.lighttpd.enable = true;

    services.lighttpd.cgit = {
      enable = true;
      package = cgit;
      configText = (lib.generators.toKeyValue { } {
        css = "/custom.css";
        logo = "/cgit.png";
        favicon = "/favicon.ico";
        about-filter = "${cgit}/lib/cgit/filters/about-formatting.sh";
        source-filter = "${cgit}/lib/cgit/filters/syntax-highlighting.py";
        auth-filter = "${auth}/libexec/auth-filter";
        clone-url =
          (lib.concatStringsSep " " [ "git@ckie.dev:$CGIT_REPO_URL" ]);
        enable-log-filecount = 1;
        enable-log-linecount = 1;
        enable-git-config = 1;
        enable-index-owner = 0;
        enable-blame = 1;
        enable-commit-graph = 1;
        root-title = "git.ckie.dev";
        root-desc = "the cookie git";
        scan-path = config.cookie.bindfs.gitolite-rottpd.dest;
      }) + ''
        readme=:README.md
        readme=:readme.md
        readme=:README.mkd
        readme=:readme.mkd
        readme=:README.rst
        readme=:readme.rst
        readme=:README.html
        readme=:readme.html
        readme=:README.htm
        readme=:readme.htm
        readme=:README.txt
        readme=:readme.txt
        readme=:README
        readme=:readme
        readme=:INSTALL.md
        readme=:install.md
        readme=:INSTALL.mkd
        readme=:install.mkd
        readme=:INSTALL.rst
        readme=:install.rst
        readme=:INSTALL.html
        readme=:install.html
        readme=:INSTALL.htm
        readme=:install.htm
        readme=:INSTALL.txt
        readme=:install.txt
        readme=:INSTALL
        readme=:install
      '';
    };

    systemd.services.lighttpd.serviceConfig = {
      ProtectSystem = "strict";
      ReadWritePaths =
        [ "/run/gitolite-rottpd" "/run/cgito" "/var/cache/cgit" ];
      CapabilityBoundingSet = "cap_setuid cap_setgid";
      DeviceAllow = [ ];
      NoNewPrivileges = "true";
      ProtectControlGroups = "true";
      ProtectClock = "true";
      PrivateDevices = "true";
      PrivateTmp = "true";
      ProtectHome = "true";
      ProtectHostname = "true";
      ProtectKernelLogs = "true";
      ProtectKernelModules = "true";
      ProtectKernelTunables = "true";
      RemoveIPC = "true";
      ProtectProc = "invisible";
      RestrictAddressFamilies = [ "~AF_UNIX" "~AF_NETLINK" ];
      RestrictSUIDSGID = "true";
      RestrictRealtime = "true";
      LockPersonality = "true";
      SystemCallArchitectures = "native";
      ProcSubset = "pid";
    };

    services.gitolite = {
      enable = true;
      user = "git";
      group = "git";
      adminPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3uTwzSSMAPg84fwbNp2cq9+BdLFeA1VzDGth4zCAbz https://ckie.dev";
      extraGitoliteRc = ''
        push( @{$RC{ENABLE}}, 'webauth' );
        push( @{$RC{ENABLE}}, 'ssh-authkeys-split' );
      '';
      package = pkgs.gitolite.overrideAttrs (orig: {
        patches = (orig.patches or [ ])
          ++ [ ./0002-PostUpdate-master-main.patch ];
        postPatch = ''
          ${orig.postPatch}
          cat >./src/commands/webauth <<EOF
          #!/bin/sh
          exec ${auth}/libexec/gitolite-cmd
          EOF
          chmod +x src/commands/webauth
        '';
      });
    };

    cookie.bindfs.gitolite-rottpd = {
      source = "/var/lib/gitolite/repositories";
      dest = "/run/gitolite-rottpd";
      args = "-u lighttpd -g lighttpd -p 0400,u+D";
      wantedBy = [ "lighttpd.service" ];
    };

    cookie.bindfs.cgito-state = {
      source = "/run/cgito";
      overlay = true;
      args = "-M lighttpd,git -p 0600,u+D";
      wantedBy = [ "lighttpd.service" ];
    };

    services.nginx = {
      virtualHosts.${cfg.host} = let
        root = pkgs.runCommandLocal "webroot" { } ''
          mkdir $out
          cp ${cgit}/cgit/*.{css,txt,ico} $out/
          cp ${./webroot}/* $out/
        '';
      in {
        locations = {
          "/".extraConfig = ''
            rewrite ^/$ /cgit last;
            root ${root};
          '';
          "~ /cgit(?:/|$)" = {
            proxyPass =
              "http://127.0.0.1:${toString config.services.lighttpd.port}";
          };
        };
        extraConfig = ''
          access_log /var/log/nginx/cgit.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "cgit" ];
  };
}
