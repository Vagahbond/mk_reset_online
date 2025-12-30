{
  description = "MarioCrade";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    nixpkgs,
    self,
    ...
  }: let
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ] (system: function nixpkgs.legacyPackages.${system});

    dbName = "mk_reset";
    dbUserName = "mk_reset";
    dbPassword = "password";

    configure = ''
      psql -h localhost -p 5432 -U $USER -d postgres -c "CREATE ROLE ${dbUserName} WITH LOGIN CREATEDB REPLICATION;"
      psql -h localhost -p 5432 -U $USER -d postgres -c "CREATE USER ${dbUserName} WITH PASSWORD '${dbPassword}';"
      psql -h localhost -p 5432 -U $USER -d postgres -c "CREATE DATABASE ${dbName} WITH OWNER ${dbUserName};";
    '';
  in {
    nixosModules = forAllSystems (pkgs: {
      default = {
        lib,
        config,
        ...
      }:
        (import ./nix/module.nix {inherit lib pkgs config;})
        // (import ./nix/options.nix {inherit lib;});
    });

    packages = forAllSystems (pkgs: {
      mkReset = pkgs.callPackage ./nix/package.nix;
      default = self.packages.${pkgs.stdenv.hostPlatform.system}.mkReset;
    });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShell {
        buildInputs = [
          pkgs.python3
          pkgs.python313Packages.gunicorn
          pkgs.python313Packages.pip
          pkgs.python313Packages.psycopg2-binary
          pkgs.python313Packages.trueskill
          pkgs.python313Packages.numpy
          pkgs.python313Packages.bcrypt
          pkgs.python313Packages.flask
          pkgs.python313Packages.requests
          pkgs.python313Packages.flask-wtf

          pkgs.postgresql
        ];

        shellHook = ''
          alias pginit='pg_ctl -D data init;';
          alias pgstart='pg_ctl -D data -l pglogfile start -o "-k ./"; ';
          alias pgconfigure=${pkgs.writeScript "pgconfigure" configure};

          echo "pginit init database"
          echo "pgstart start database"
          echo "pgconfigure create db and user"

          echo "psql -h localhost -U mk_reset -d mk_reset -W -f backEnd/db.sql to populate db"

          echo Now developping Mario Krade!

          export POSTGRES_DB=${dbName}
          export POSTGRES_USER=${dbUserName}
          export POSTGRES_PASSWORD=${dbPassword}
          export POSTGRES_HOST=localhost
          export POSTGRES_PORT=5432
          export ADMIN_TOKEN=secret
          export ADMIN_PASSWORD_HASH=$2a$12$lLsQonpUM1UrTfjJY42eTeFvZFKXIGtKaqzCkteLcqRGiWTygzy9e
          export SECRET_KEY=secret
          export BACKEND_URL=http://localhost:8080

          alias backend_start='python -c "from backend import sync_sequences, recalculate_tiers; sync_sequences(); recalculate_tiers()" && gunicorn -w 4 -b 0.0.0.0:8080 backend:app;'
          alias frontend_start='gunicorn -w 4 -b 0.0.0.0:5000 frontend:app'

          echo "backend_start : start backend"
          echo "frontend_start: start frontend"

        '';
      };
    });
  };
}
