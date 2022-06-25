{ stdenv, coreutils, jq, writeText }:

let
  configOverrides = writeText "element-config-overrides.json" (builtins.toJSON {
    disable_guests =
      true; # disable automatic guest account registration at matrix.org
    piwik = false; # disable analytics
    brand = "Element";
    default_server_config."m.homeserver" = {
      base_url = "https://matrix.ckie.dev";
      server_name = "ckie.dev";
    };
    show_labs_settings = true;
  });
in stdenv.mkDerivation {
  pname = "element-web";
  version = "cookie";

  src = ./element.tar.gz;

  nativeBuildInputs = [ coreutils jq ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r $PWD/* $out/
    jq -s '.[0] * .[1]' "config.sample.json" "${configOverrides}" > "$out/config.json"

    runHook postInstall
  '';
}
