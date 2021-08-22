{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.isp-troll;

in with lib; {
  options.cookie.services.isp-troll = {
    enable = mkEnableOption "Enables the ISP trolling service";
  };

  config = mkIf cfg.enable {
    systemd.services.isp-troll = {
      description =
        "Shoots a bit of a speed test every so often to keep the ISP motivated";
      script =
        "${pkgs.curl}/bin/curl --output /dev/null 'https://ipv4-c001-sdv001-hot-isp.1.oca.nflxvideo.net/speedtest/range/0-26214399?c=il&n=12849&v=55&e=1629512281&t=aaf_cCyKA0xcFldekLHWbD_eMT9buCnibd16WA' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:89.0) Gecko/20100101 Firefox/89.0' -H 'Accept: */*' -H 'Accept-Language: en-US,en;q=0.5' --compressed -H 'Origin: https://fast.com' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Referer: https://fast.com/'";
      startAt = "*-*-* *:0,15,30,45:*";
    };
  };
}
