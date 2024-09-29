{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.collections.chat;

  element = (pkgs.element-desktop.override {
    element-web = config.cookie.services.matrix.elementRoot;
  });
in with lib; {
  options.cookie.collections.chat = {
    enable = mkEnableOption "Enables a collection of chat apps";
  };

  config = mkIf cfg.enable {
    home-manager.users.ckie = { ... }: {
      home.packages = with pkgs; [
        discord
        #schildichat-desktop # broken, removed

        (let # patched element-desktop with old 🥺, courtesy of @networkexception:chat.upi.li
          patched-element-web = let
            TwemojiMozilla-colr = pkgs.fetchurl {
              url =
                "https://github.com/matrix-org/matrix-react-sdk/raw/a465b1659f1f7763a1a5afcd56b7aa8513c57342/res/fonts/Twemoji_Mozilla/TwemojiMozilla-colr.woff2";
              hash = "sha256-TS2DTfotWc/C+7dKv9TYEnxognfTQ3/l8uPD5Ptozbs=";
            };

            TwemojiMozilla-sbix = pkgs.fetchurl {
              url =
                "https://github.com/matrix-org/matrix-react-sdk/raw/a465b1659f1f7763a1a5afcd56b7aa8513c57342/res/fonts/Twemoji_Mozilla/TwemojiMozilla-sbix.woff2";
              hash = "sha256-sbZGHcRiscCWrelyLQav6Q1a0x5RQInSNh/XwFlZHj8=";
            };
          in pkgs.symlinkJoin {
            name = "element-web-patched-" + pkgs.element-web.version;
            paths = with pkgs; [ element-web ];
            postBuild = ''
              dir="$out/fonts/Twemoji_Mozilla"

              colr_path="$dir/$(ls "$dir" -1 | grep colr)"
              sbix_path="$dir/$(ls "$dir" -1 | grep sbix)"

              rm "$colr_path"
              rm "$sbix_path"

              ln -s "${TwemojiMozilla-colr}" "$colr_path"
              ln -s "${TwemojiMozilla-sbix}" "$sbix_path"
            '';
          };
        in pkgs.symlinkJoin {
          name = "element-desktop-patched-" + pkgs.element-desktop.version;
          paths = with pkgs; [ element-desktop ];
          postBuild = ''
            rm "$out/share/element/webapp"

            ln -s "${patched-element-web}" "$out/share/element/webapp"

            rm "$out/bin/element-desktop"

            substitute "${pkgs.element-desktop}/bin/element-desktop" "$out/bin/element-desktop" \
              --replace "${pkgs.element-desktop}" "$out"

            chmod +x "$out/bin/element-desktop"

            rm "$out/share/element/electron/lib/electron-main.js"

            substitute "${pkgs.element-desktop}/share/element/electron/lib/electron-main.js" "$out/share/element/electron/lib/electron-main.js" \
              --replace "return asarPathPromise;" "return Promise.resolve('${patched-element-web}');"
          '';
        })

        signal-desktop
        mumble
        # nheko # Package ‘olm-3.2.16’ in /home/ckie/git/nixpkgs/pkgs/development/libraries/olm/default.nix:26 is marked as insecure, refusing to evaluate.
        slack
        tuba
      ];
      # cookie.weechat.enable = true; # more or less unused now
    };

    programs.firejail.wrappedBinaries = with pkgs;
      let inherit (config.cookie.firejail) mk;
      in mkMerge [
        # not good enough to be useful (yet), and is a nuisance
        # (mk "element-desktop" { pkg = element; })
        # (mk "Discord" { pkg = discord; })
      ];
  };
}
