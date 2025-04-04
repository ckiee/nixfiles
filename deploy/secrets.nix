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
  function mkRng {
    < /dev/urandom tr -dc '[a-z0-9A-Z@-Z(-.]' | head -c ${"$"}{1:-255}
  }
  ${concatStringsSep "\n" (mapAttrsToList (host: hostConfig:
    let
      cfg = hostConfig.config.cookie.secrets;
      machinePubkey = hostConfig.config.cookie.state.sshPubkey;
    in ''
      mkdir -p encrypted/'${host}' || true
      ${
        concatStringsSep "\n" (mapAttrsToList (_: secret:
          let secretFn = baseNameOf secret.source;
              niceEcho = msg:
                ''echo "[${secretFn}:${host}] ${msg}"'';
          in ''
            function get_enchash {
              sha512sum '${secret.source}'
              echo '${machinePubkey}' | sha512sum
            }

            ${
              optionalString (secret.generateCommand != null) ''
                if ! [ -e '${secret.source}' ]; then
                  ${niceEcho "file missing, generating"}
                  ${secret.generateCommand}
                fi
              ''
            }

            if [ "$(cat encrypted/'${host}'/'${secretFn}'.HASH)" != "$(get_enchash)" ]; then
              ${niceEcho "sha512 changed, re-encrypting"}
              ${pkgs.rage}/bin/rage -a -r '${machinePubkey}' -r '${userPubkey}' -o 'encrypted/${host}/${secretFn}' '${secret.source}'
            fi
            get_enchash > encrypted/'${host}'/'${secretFn}'.HASH
          '') cfg)
      }
    '') (filterAttrs (_: n: n.config.cookie.state.sshPubkey != null)
      uncheckedNodes))}
''
