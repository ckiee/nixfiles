{ uncheckedNodes, ... }:

let
  sources = import ../nix/sources.nix;
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
            function get_enchash {
              sha512sum '${secret.source}'
              echo '${machinePubkey}' | sha512sum
            }

            if [ "$(cat encrypted/'${host}'/'${secretFn}'.HASH)" != "$(get_enchash)" ]; then
              echo "[${secretFn}:${host}] sha512 changed, re-encrypting"
              ${pkgs.rage}/bin/rage -a -r '${machinePubkey}' -r '${userPubkey}' -o 'encrypted/${host}/${secretFn}' '${secret.source}'
            fi
            get_enchash > encrypted/'${host}'/'${secretFn}'.HASH
          '') cfg)
      } # TODO filter for !secret.runtime
    '') (filterAttrs (_: n: n.config.cookie.machine-info.sshPubkey != null)
      uncheckedNodes))}
''