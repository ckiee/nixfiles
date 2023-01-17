{ root }:
with builtins;
with import <nixpkgs/lib>;

let secrets = /. + root + /secrets;
# XXX: need to manually delete the old ./secrets/matrix-secret-config.json to regenerate this.
# it's intentional since overwriting secrets silently feels dangerous.
in __trace (toJSON {
  registration_shared_secret =
    fileContents (secrets + "/matrix-synapse-registration");
  email = {
    smtp_pass = fileContents (secrets + "/matrix-smtp-password");
  };
}) 0
