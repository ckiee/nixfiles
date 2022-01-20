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
    ./headscale.nix
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
    # Home baked
    ./ronthecookieme.nix
    ./rtc-files.nix
    ./comicfury.nix
    ./owo-bot.nix
    ./ffg-bot.nix
    ./redirect-farm.nix
    ./ckiesite.nix
    ./daiko.nix
    ./isp-troll.nix
    ./anonvote-bot.nix
    ./aldhy
  ];
}
