{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.school-schedule;
  desktop =
    pkgs.writeTextFile { # theres a special helper for .desktop entries but i'm lazy and this works!
      name = "school-schedule.desktop";
      destination = "/share/applications/school-schedule.desktop";
      text = ''
        [Desktop Entry]
        Name=School Schedule
        Exec=${pkgs.feh}/bin/feh /home/ckie/Sync/school/sched.jpeg
        Type=Application
        Terminal=false
      '';
    };
in with lib; {
  options.cookie.school-schedule = {
    enable = mkEnableOption "Enables the desktop entry for the school schedule";
  };

  config = mkIf cfg.enable {
    home.packages = [ desktop ];
  };
}
