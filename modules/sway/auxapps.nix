{ util, config, lib, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.cookie.sway;
  inherit (util) mkRequiresScript;
in {
  config = mkIf cfg.enable {
    home-manager.users.ckie = { config, nixosConfig, ... }: {
      systemd.user.services = let
        mkSvc = exec: {
          Service = {
            ExecSearchPath =
              "/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin";
            ExecStart = exec;
          };
          Install.WantedBy = [ "sway-session.target" ];
          Unit = {
            After = [ "graphical-session-pre.target" ];
            PartOf = [ "graphical-session.target" ];
          };
        };
      in mkMerge [
        {
          kdeconnectd =
            mkSvc "${pkgs.plasma5Packages.kdeconnect-kde}/libexec/kdeconnectd";
          kdeconnect-indicator = mkSvc
            "${pkgs.plasma5Packages.kdeconnect-kde}}/bin/kdeconnect-indicator";
          nm-applet = mkSvc "${pkgs.networkmanagerapplet}/bin/nm-applet";
          # x11: Ctrl+Alt+E to activate, wayland: 2nd instance opens gui, first is daemon
          emote = mkSvc "${pkgs.emote}/bin/emote";
          fehbg = mkIf (nixosConfig.cookie.desktop.wm == "i3") (mkSvc
            "${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${
              ./backgrounds/farlands.jpg
            }");
          polkit-gnome-auth-agent = mkSvc
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          oszwatch = # depends on impure fs contents @ /mnt/games
            mkIf (nixosConfig.networking.hostName == "cookiemonster")
            (mkSvc "${mkRequiresScript ./scripts/oszwatch}");
          mpvshotwatch = (mkSvc "${mkRequiresScript ./scripts/mpvshotwatch}");
          musicwatch = mkSvc "${mkRequiresScript ./scripts/musicwatch}";
          firefox = mkSvc "firefox";
          cantata = mkIf nixosConfig.cookie.mpd.enable (mkSvc "cantata");
          # ledc = mkIf nixosConfig.cookie.ledc.enable (mkSvc "ledc");
          thunderbird = mkSvc "thunderbird";
          cliphistd = mkSvc "wl-paste --watch cliphist store -max-items 100";
        }
        (mkIf nixosConfig.cookie.collections.chat.enable {
          discord = mkSvc "Discord";
          element = mkSvc "element-desktop";
          signal = mkSvc "signal-desktop";
          mattermost = mkSvc "mattermost-desktop";
          # nheko = mkSvc "nheko";
          # slack = mkSvc "slack";
        })
      ];
    };
  };
}

