{
  stdenvNoCC,
  pkgs,
  lib,
}:
stdenvNoCC.mkDerivation {
  name = "mk_reset";
  version = "1.0.0";

  src = lib.fileset.toSource {
    root = ./..;
    fileset = lib.fileset.unions [
      ../backEnd/backend.py
      ../backEnd/db.sql

      ../frontEnd/static
      ../frontEnd/templates
      ../frontEnd/frontend.py
    ];
  };

  installPhase = ''
    mkdir -p $out/
    cp -r . $out/
  '';

  propagatedBuildInputs = with pkgs.python313Packages; [
    # Allows using it in a writeScript later
    gunicorn
    psycopg2-binary
    trueskill
    numpy
    bcrypt
    flask
    requests
    flask-wtf
  ];
}
