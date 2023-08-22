with import ./repl.nix; {
  sshOpts = [ "-t" ]; # interactive for sudo prompt
  magicRollback = false; # ): https://github.com/serokell/deploy-rs/issues/78#issuecomment-1133054583
  nodes.thonkcookie = {
    hostname = "thonkcookie";
    fastConnection = true; # TODO: dynamic
    profiles.system = {
      user = "root";
      path = (import sources.deploy-rs).lib.x86_64-linux.activate.nixos
        nodes.thonkcookie;
    };
  };
}
# NIV_OVERRIDE_nixpkgs="$(realpath ~/git/nixpkgs)" NIV_OVERRIDE_deploy_rs="$(realpath ~/git/deploy-rs)" c thonkcookie
