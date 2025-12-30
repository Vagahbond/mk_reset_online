{lib, ...}:
with lib; {
  options = {
    services.mkReset = {
      enable = mkEnableOption "Mk Reset (classements)";

      frontend = {
        port = lib.mkOption {
          type = lib.types.str;
          description = "Port for frontend app";
          default = "8653";
        };
      };

      backend = {
        port = lib.mkOption {
          type = lib.types.str;
          description = "Port for backend app";
          default = "8653";
        };
      };

      envFile = mkOption {
        description = "Environment variables for the app";
        type = lib.types.path;
        default = null;
      };
    };
  };
}
