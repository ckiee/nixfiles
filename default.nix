{ config, pkgs, lib, sources, ... }:

with lib;
with builtins;

{
  imports = [ ./modules ];
  nixpkgs.config.allowUnfree = true;
  system = {
    configurationRevision = getEnv "CKIE_CONFIG_REV";
    nixos.revision = sources.nixpkgs.rev;
  };

  _module.args.sources = import ./nix/sources.nix;

  time.timeZone = "Israel";

  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;
  boot.tmpOnTmpfs = true;

  networking.networkmanager.enable = true;

  users.mutableUsers = false;
  users.users.root = {
    hashedPassword = (import ./secrets/unix-password.nix).root;
  };

  # Nasty obscure EBUSY errors will come without this
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile"; # max FD count
    value = "unlimited";
  }];

  # Prune the journal to avoid this:
  # $ du -sh /var/log/journal/
  # 4.1G    /var/log/journal/
  services.journald.extraConfig = ''
    SystemMaxUse=2G
    MaxFileSec=40day
  '';

  environment.systemPackages = with pkgs;
    [ vim wget ]; # More in modules/big.nix. Don't add a lot!

  cookie = {
    # Daemons
    services = {
      ssh.enable = true;
      tailscale.enable = mkDefault true;
    };
    # Etc
    wireguard.enable = config.cookie.state.bootable;
    binary-caches.enable = true;
    nix.enable = true;
    cookie-overlay.enable = true;
    ipban.enable = true;
  };

  home-manager.users.ckie = { nixosConfig, pkgs, ... }: {
    # for hmporter support
    home.sessionVariables.TZ = nixosConfig.time.timeZone;
    cookie = {
      shell = {
        enable = true;
        bash = true;
        fish = true;
      };
      nixpkgs-config.enable = true;
    };
  };
}
