let
  pkgs = import <nixpkgs> {};
  unstablePkgs = import <nixos-unstable> {};
  lib = import <lib> {};
  config = import <config> {};

  configPath = /home/sceptri/Documents/Dev/homelab/.;
in
  pkgs.mkShell {
    buildInputs = with pkgs; [
      (unstablePkgs.julia.withPackages
        [
          "DrWatson"
          "Revise"
          "DifferentialEquations"
          "Plots"
          "IJulia"
        ])
      gnumake
      imagemagick
      jupyter-all
    ];
    shellHook = ''
      julia -e 'using Pkg, IJulia; IJulia.installkernel("julia-env"; julia=`$(Sys.which("julia"))`); Pkg.activate("."); IJulia.installkernel("julia-local", "--project=$(Base.active_project())"; julia=`$(Sys.which("julia"))`);'
      echo "Welcome to Master Thesis shell"
    '';
  }
