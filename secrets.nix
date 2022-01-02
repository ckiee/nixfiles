{ uncheckedNodes, ... }:

let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
  userPubkey = lib.fileContents ./id_ed25519.pub;
  inherit (pkgs) lib;
in with lib;

pkgs.writeScript "cookie-rager-encrypt" ''
  set -e
  cd $(${pkgs.git}/bin/git rev-parse --show-toplevel)
  ${concatStringsSep "\n" (mapAttrsToList (host: hostConfig:
    let
      cfg = hostConfig.config.cookie.secrets;
      machinePubkey = hostConfig.config.cookie.machine-info.sshPubkey;
    in ''
      mkdir -p encrypted/'${host}' || true
      ${
        concatStringsSep "\n" (mapAttrsToList (_: secret:
          let secretFn = baseNameOf secret.source;
          in ''
            if [ "$(cat encrypted/'${host}'/'${secretFn}'.HASH)" != "$(sha512sum '${secret.source}')" ]; then
              echo "[${secretFn}:${host}] sha512 changed, re-encrypting"
              ${pkgs.rage}/bin/rage -a -r '${machinePubkey}' -r '${userPubkey}' -o 'encrypted/${host}/${secretFn}' '${secret.source}'
            fi
            sha512sum '${secret.source}' > encrypted/'${host}'/'${secretFn}'.HASH
          '') cfg)
      } # TODO filter for !secret.runtime
    '') uncheckedNodes)}
''
