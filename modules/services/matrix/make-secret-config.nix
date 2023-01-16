with builtins;
with import <nixpkgs/lib>;
let secrets = ../../../secrets;
in toJSON {
  registration_shared_secret =
    fileContents (secrets + "/matrix-synapse-registration");
  email.smtp_pass = fileContents (secrets + "/matrix-synapse-smtp-pass");
}
