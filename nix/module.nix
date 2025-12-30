{
  config,
  lib,
  self,
  ...
}: let
  cfg = config.services.mkReset;

  user = "mk_reset";

  startBackend = lib.pkgs.writers.writeBash "start_mario_crade_backend.sh" ''
    cd ${self.packages.${lib.pkgs.stdenv.hostPlatform.system}.mkReset}/backEnd
    python -c 'from backend import sync_sequences, recalculate_tiers; sync_sequences(); recalculate_tiers();';
    gunicorn -w 4 -b 0.0.0.0:${cfg.backend.port} backend:app;
  '';

  startFrontend = lib.pkgs.writers.writeBash "start_mario_crade_frontend.sh" ''
    cd ${self.packages.${lib.pkgs.stdenv.hostPlatform.system}.mkReset}/frontEnd
    gunicorn -w 4 -b 0.0.0.0:${cfg.frontend.port} frontend:app;
  '';
in {
  config = lib.mkIf cfg.enable {
    users.users.${user} = {
      home = "/home/${user}";
      group = user;
      isSystemUser = true;
    };

    users.groups.${user}.members = [user];

    systemd = {
      services.user.services.mario-crade-frontend = {
        enable = true;
        after = ["network.target"];
        description = "Mario Krade service";
        serviceConfig = {
          Type = "simple";
          ExecStart = "${startFrontend}/bin/start_mario_crade_frontend.sh";
        };
      };
      services.user.services.mario-crade-backend = {
        enable = true;
        after = ["network.target"];
        description = "Mario Krade service";
        serviceConfig = {
          Type = "simple";
          ExecStart = "${startBackend}/bin/start_mario_crade_backend.sh";
        };
      };
    };

    services = {
      postgresql = {
        enable = true;
        ensureDatabases = [cfg.config.dbname];
        ensureUsers = [
          {
            name = cfg.config.dbuser;
            ensureDBOwnership = true;
          }
        ];
      };
    };
  };
}
