{
  description = "libtexprintf library provide tools to pretty print math in mono-space fonts, using a tex-like syntax";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    libtexprintf-src = {
      url = "github:bartp5/libtexprintf/v1.31"; # Upstream
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, libtexprintf-src }:
    flake-utils.lib.eachDefaultSystem (system: # flake-utils give you shorthand for all systems, so you dont define darwin/x86_64 etc separately
      let
        pkgs = nixpkgs.legacyPackages.${system};

        utftex = pkgs.stdenv.mkDerivation { # this mkDerivation already contain default toolchain (GCC, make, bin utils, core utils), thus no need to download additional toolchain
          pname = "utftex";
          version = "1.31";
          src = libtexprintf-src;
          nativeBuildInputs = [ pkgs.autoreconfHook ]; # This use configure.ac in repo to generate ./configure
          preCheck = '' # Test script are in bash script, but mkDerivation only have /bin/sh, this patch sh to bash
            patchShebangs .
          '';
          doCheck = true;

          meta = with pkgs.lib; {
            description = "Pretty-print TeX math as UTF-8 text";
            homepage = "https://github.com/bartp5/libtexprintf";
            license = licenses.gpl3Only;
            mainProgram = "utftex";
            platforms = platforms.unix;
          };
        };
      in
      {
        packages.default = utftex;
        packages.utftex = utftex;

        apps.default = flake-utils.lib.mkApp { drv = utftex; };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ utftex ];
          packages = [ pkgs.gdb ];
        };
      }
    );
}
