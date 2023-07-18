{ ... }:

{
  imports = [
    # Supporting
    ./postgres.nix
    ./nginx.nix
    # System
    ./avahi.nix
    ./ssh
    ./prometheus
    ./tailscale.nix
    ./coredns
    ./nix-serve.nix
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
    ./gitd
    ./jitsi.nix
    ./headscale.nix
    ./elastic
    ./go-neb.nix
    ./heisenbridge
    ./akkoma-test.nix
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
  ];
}
