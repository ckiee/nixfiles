{ ... }:

{
  home-manager.users.ron = { ... }: {
    imports = [ ./polybar.nix ];
  };
}
