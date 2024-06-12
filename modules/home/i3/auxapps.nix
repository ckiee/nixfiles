{ util, config, lib, pkgs, nixosConfig, ... }:

with lib;
with builtins;

let
  cfg = config.cookie.i3;
  inherit (util) mkRequiresScript;
in {
  config = mkIf cfg.enable {
    systemd.user.services = let
      mkSvc = exec: {
        Service = {
          ExecSearchPath = "/run/current-system/sw/bin:${config.home.homeDirectory}/.nix-profile/bin";
          ExecStart = exec;
        };
        Install.WantedBy = [ "graphical-session.target" ];
        Unit = {
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };
      };
    in mkMerge [
      {
        kdeconnectd = mkSvc "${pkgs.kdeconnect}/libexec/kdeconnectd";
        kdeconnect-indicator =
          mkSvc "${pkgs.kdeconnect}/bin/kdeconnect-indicator";
        nm-applet = mkSvc "${pkgs.networkmanagerapplet}/bin/nm-applet";
        emote = mkSvc "${pkgs.emote}/bin/emote"; # Ctrl+Alt+E to activate
        fehbg = mkSvc
          "${pkgs.feh}/bin/feh --no-fehbg --bg-scale ${./backgrounds/1080pified_impression_soleil_levant.png}";
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
      }
      (mkIf nixosConfig.cookie.collections.chat.enable {
        discord = mkSvc "Discord";
        element = mkSvc "element-desktop";
        nheko = mkSvc "nheko";
        slack = mkSvc "slack";
      })
    ];
  };
}

