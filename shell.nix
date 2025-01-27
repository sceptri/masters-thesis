let
  pkgs = import <nixpkgs> {};
  lib = import <lib> {};
  config = import <config> {};
  configPath = builtins.getEnv "NIXOS_CONFIGURATION_DIR" + "/.";
  quartoPreRelease = extraRPackages:
    pkgs.callPackage (configPath + "/packages/quarto/preRelease.nix")
    (with pkgs lib config; {extraRPackages = extraRPackages;});

  rPackages = with pkgs.rPackages; [
    quarto
    languageserver
    knitr
    tidyverse
  ];
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      pkgs.texlive.combined.scheme-full
      pandoc
      xclip
      (
        rWrapper.override {
          packages = rPackages;
        }
      )
      (
        quartoPreRelease rPackages
      )
    ];

    shellHook = ''
      echo "Welcome to Masters Thesis shell"
    '';
  }
