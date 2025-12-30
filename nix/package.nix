{
  lib,
  stdenv,
  rustPlatform,
  makeBinaryWrapper,
  installShellFiles,
  versionCheckHook,
  use-nom ? true,
  nix-output-monitor ? null,
  rev ? "dirty",
}: {}
