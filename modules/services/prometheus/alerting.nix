{ config, lib, pkgs, ... }:

with lib;

let cfg = config.cookie.services.prometheus;
in {
  config = mkIf cfg.enableServer {
    services.prometheus.alertmanager = {
      enable = true;
      configuration = {
        route = {
          group_by = [ "alertname" "cluster" "service" ];
          group_wait = "30s";
          group_interval = "30s";
          repeat_interval = "30s";
          receiver = "neb";
        };

        inhibit_rules = [{
          source_matchers = [ ''severity="critical"'' ];
          target_matchers = [ ''severity="warning"'' ];
          # Apply inhibition if the alertname is the same.
          # CAUTION:
          #   If all label names listed in `equal` are missing
          #   from both the source and target alerts,
          #   the inhibition rule will apply!
          equal = [ "alertname" "cluster" "service" ];
        }];

        receivers = [{
          name = "neb";
          webhook_configs = [{
            url =
              "http://127.0.0.1${config.services.go-neb.bindAddress}/services/hooks/YWxlcnRtYW5hZ2VyX3NlcnZpY2U"; # to go-neb
            send_resolved = true;
          }];
        }];
      };
    };

    cookie.secrets.go-neb = {
      source = "./secrets/go-neb.env";
      permissions = "0400";
    };

    services.go-neb = {
      enable = true;
      baseUrl = "http://localhost";
      secretFile = config.cookie.secrets.go-neb.dest;
      config = {
        clients = [{
          UserId = "@infra:ckie.dev";
          AccessToken = "$INFRA_BOT_TOKEN";
          HomeServerUrl = "https://matrix.ckie.dev";
          Sync = true;
          AutoJoinRooms = true;
          DisplayName = "Bot";
        }];
        services = [{
          ID = "alertmanager_service";
          Type = "alertmanager";
          UserId = "@infra:ckie.dev";
          Config = {
            # `/services/hooks/<base64 encoded service ID>`
            webhook_url = "http://localhost:4050/services/hooks/YWxlcnRtYW5hZ2VyX3NlcnZpY2U";
            rooms = {
              # cookiespace infra channel
              "!QxKcDjplqOVhgordcV:ckie.dev" = {
                text_template = ''
                  {{range .Alerts -}} [{{ .Status }}] {{index .Labels "alertname" }}: {{index .Annotations "description"}} {{ end -}}
                '';

                # $$severity otherwise envsubst replaces $severity with an empty string
                html_template = ''
                  {{range .Alerts -}}
                    {{ $$severity := index .Labels "severity" }}
                    {{ if eq .Status "firing" }}
                      {{ if eq $$severity "critical"}}
                        <font color='red'><b>[FIRING - CRITICAL]</b></font>
                      {{ else if eq $$severity "warning"}}
                        <font color='orange'><b>[FIRING - WARNING]</b></font>
                      {{ else }}
                        <b>[FIRING - {{ $$severity }}]</b>
                      {{ end }}
                    {{ else }}
                      <font color='green'><b>[RESOLVED]</b></font>
                    {{ end }}
                    {{ index .Labels "alertname"}}: {{ index .Annotations "summary"}}
                    (
                      <a href="{{ index .Annotations "grafana" }}">📈 Grafana</a>,
                      <a href="{{ .GeneratorURL }}">🔥 Prometheus</a>,
                      <a href="{{ .SilenceURL }}">🔕 Silence</a>
                    )<br/>
                  {{end -}}'';
                msg_type = "m.text"; # Must be either `m.text` or `m.notice`
              };
            };
          };
        }];
      };
    };
  };
}
