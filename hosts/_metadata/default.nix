{ config, pkgs, lib, nodes, ... }:
with lib;

let
  userPubkey = lib.fileContents ./id_ed25519.pub;
  util = import ../../modules/util/util.nix { inherit pkgs lib; };
  inherit (util) fileNameFromPath;
in {
  options.system = {
    # Mock for morph
    nixos.release = mkOption {
      readOnly = true;
      type = types.str;
      default = "00.00";
    };
    build.toplevel = mkOption {
      readOnly = true;
      default = pkgs.writeScript "cookie-rager-encrypt" ''
        set -e
        cd $(${pkgs.git}/bin/git rev-parse --show-toplevel)
        ${concatStringsSep "\n" (mapAttrsToList (host: hostConfig:
          let
            cfg = hostConfig.config.cookie.secrets;
            machinePubkey = hostConfig.config.cookie.machine-info.sshPubkey;
          in ''
            mkdir -p encrypted/'${host}' || true
            ${concatStringsSep "\n" (mapAttrsToList (_: secret:
              let
                secretFn = fileNameFromPath secret.source;
              in ''
                if [ "$(cat encrypted/'${host}'/'${secretFn}'.HASH)" != "$(sha512sum '${secret.source}')" ]; then
                  echo "[${secretFn}:${host}] sha512 changed, re-encrypting"
                  ${pkgs.rage}/bin/rage -a -r '${machinePubkey}' -r '${userPubkey}' -o 'encrypted/${host}/${secretFn}' '${secret.source}'
                fi
                sha512sum '${secret.source}' > encrypted/'${host}'/'${secretFn}'.HASH
              '') cfg)} # TODO filter for !secret.runtime
          '') ((filterAttrs (host: _: host != "_metadata")) nodes))}
      '';
    };
  };
}
