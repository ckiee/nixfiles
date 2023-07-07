{ lib, config, pkgs, utils, ... }:

with lib;

let
  iface = "wlp45s0f3u4";
  configFile = pkgs.writeText "hostapd.conf" ''
    interface=${iface}
    bridge=br0
    driver=nl80211
    ssid=${config.networking.hostName}
    hw_mode=a
    max_num_sta=5
    country_code=IL

    # logging (debug level)
    logger_syslog=-1
    logger_syslog_level=4
    logger_stdout=-1
    logger_stdout_level=debug

    wpa=2
    auth_algs=3
    wpa_pairwise=CCMP
    wpa_key_mgmt=WPA-PSK
    wpa_passphrase=REPLACE
    wmm_enabled=1
    ieee80211ac=1
    ieee80211n=1
    ieee80211d=1
    eapol_version=1
    ieee80211w=1
    okc=0

    # announce beacon every .5s, we're in devel, it's convenient
    beacon_int=500

    require_ht=1
    channel=36
    ${
    /* require_vht=0
       vht_oper_chwidth=1
       vht_oper_centr_freq_seg0_idx=42
       vht_capab=[MAX-MPDU-11454][SHORT-GI-80][TX-STBC-12][RX-STBC-1][SU-BEAMFORMEE][HTC-VHT]
    */
    # they broke VHT in the kernel driver
    ""}

    ht_capab=[HT40+][SHORT-GI-20][SHORT-GI-40][DSSS_CCK-40][TX-STBC-12][RX-STBC-12]
  '';
  escapedInterface = utils.escapeSystemdPath iface;

  cfg = config.cookie.hostapd;
in {
  options.cookie.hostapd = { enable = mkEnableOption "Enables hostapd"; };

  config = mkIf cfg.enable {
    cookie.secrets.hostapd-passphrase = {
      source = "./secrets/hostapd_passphrase";
      permissions = "0400";
      wantedBy = "hostapd.service";
    };

    services.udev.packages = singleton pkgs.crda;

    networking.networkmanager.unmanaged = singleton iface;

    systemd.services.hostapd = {
      path = [ pkgs.hostapd ];
      after = [ "sys-subsystem-net-devices-${escapedInterface}.device" ];
      bindsTo = [ "sys-subsystem-net-devices-${escapedInterface}.device" ];
      requiredBy = [ "network-link-${iface}.service" ];

      serviceConfig.Restart = "always";

      script = ''
        rm /run/hostapd.conf || true
        touch /run/hostapd.conf
        chmod 600 /run/hostapd.conf
        sed -e 's/REPLACE/'"$(cat '${config.cookie.secrets.hostapd-passphrase.dest}')"'/' ${configFile} > /run/hostapd.conf
        hostapd /run/hostapd.conf
      '';
    };
  };
}
