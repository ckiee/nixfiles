{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.gitd;
  cgit = pkgs.cgit;
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
      configText = (lib.generators.toKeyValue { } {
        css = "/cgit.css";
        logo = "/cgit.png";
        favicon = "/favicon.ico";
        about-filter = "${cgit}/lib/cgit/filters/about-formatting.sh";
        source-filter = "${cgit}/lib/cgit/filters/syntax-highlighting.py";
        clone-url = (lib.concatStringsSep " " [
          "https://$HTTP_HOST$SCRIPT_NAME/$CGIT_REPO_URL"
          "ssh://git@ckie.dev:$CGIT_REPO_URL"
        ]);
        enable-log-filecount = 1;
        enable-log-linecount = 1;
        enable-git-config = 1;
        root-title = "git.ckie.dev";
        root-desc = "the cookie git";
        scan-path = config.cookie.bindfs.gitolite-rottpd.dest;
      });
    };

    services.gitolite = {
      enable = true;
      user = "git";
      group = "git";
      adminPubkey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIH3uTwzSSMAPg84fwbNp2cq9+BdLFeA1VzDGth4zCAbz https://ckie.dev";
    };

    cookie.bindfs.gitolite-rottpd = {
      source = "/var/lib/gitolite/repositories";
      dest = "/run/gitolite-rottpd";
      args = "-u lighttpd -g lighttpd -p 0400,u+D";
      wantedBy = [ "lighttpd.service" ];
    };

    services.nginx = {
      virtualHosts.${cfg.host} = let
        root = pkgs.runCommandLocal "webroot" { } ''
          mkdir $out
          cp ${cgit}/cgit/*.{css,txt,png,ico} $out/
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
