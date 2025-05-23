{ ... }:

{
  imports = [
    # Supporting
    ./postgres
    ./nginx.nix
    # System
    ./avahi.nix
    ./ssh
    ./prometheus
    ./tailscale.nix
    ./coredns
    ./nix-serve.nix
    ./chronyc.nix
    # User
    ./minecraft.nix
    ./grafana.nix
    ./znc.nix
    ./matrix
    ./matterbridge.nix
    ./mailserver
    ./among-sus.nix
    ./printer.nix
    ./scanner
    ./syncthing.nix
    ./octoprint.nix
    ./soju.nix
    ./mcid.nix # daniel's
    ./alvr-bot.nix
    ./hydra
    ./wikidict.nix
    ./pleroma
    ./lighttpd.nix
    # ./gitd
    ./jitsi.nix
    ./headscale.nix
    ./elastic
    ./go-neb.nix
    ./heisenbridge
    ./akkoma-test.nix
    ./transmission
    ./vaultwarden
    ./ergo
    ./radicale
    ./paperless
    ./stfed.nix
    ./gotosocial
    ./transqsh.nix
    ./coqui
    ./miniflux
    ./archivebox
    ./catcam
    ./hedgedoc
    ./vmware-host
    ./changedetection
    ./immich
    ./garage
    ./mattermost
    ./sosse
    # Home baked
    ./rtcme.nix
    ./rtc-files.nix
    ./comicfury.nix
    ./owo-bot.nix
    ./ffg-bot.nix
    ./redirect-farm.nix
    ./ckiesite
    ./daiko.nix
    ./isp-troll.nix
    ./anonvote-bot.nix
    ./aldhy
    ./net-offload
    ./tonsi-li
    ./websync.nix
    ./pupcat.nix
    ./shortcat
  ];
}
