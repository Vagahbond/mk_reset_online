{lib, ...}:
with lib; {
  options = {
    services.mkReset = {
      enable = mkEnableOption "Mk Reset (classements)";

      backendPort = mkOption {
        description = "What port to run the backend on.";
        type = types.int;
        default = 8653;
      };

      frontendPort = mkOption {
        description = "What port to run the frontend on.";
        type = types.int;
        default = 8653;
      };

      envFile = mkOption {
        description = "Environment variables for the app";
        type = types.path;
        default = null;
      };
    };
  };
}
