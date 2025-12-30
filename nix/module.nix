{
  config,
  lib,
  ...
}: let
  cfg = config.services.mkReset;
in {
  config = lib.mkIf cfg.enable {
    users.users.mk_reset = {
      home = "/home/mk_reset";
      group = "mk_reset";
      isSystemUser = true;
    };

    users.groups.mk_reset.members = ["mk_reset"];

    services = {
    };

    systemd.tmpfiles.rules = [
      "d ${config.users.users.learnify.home}/postgres-data 755 root root"
    ];
  };
}
