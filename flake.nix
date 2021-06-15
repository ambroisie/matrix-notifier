{
  description = "Ambroisie's blog";

  inputs = {
    futils = {
      type = "github";
      owner = "numtide";
      repo = "flake-utils";
      ref = "master";
    };

    nixpkgs = {
      type = "github";
      owner = "NixOS";
      repo = "nixpkgs";
      ref = "nixpkgs-unstable";
    };

    pre-commit-hooks = {
      type = "github";
      owner = "cachix";
      repo = "pre-commit-hooks.nix";
      ref = "master";
      inputs = {
        flake-utils.follows = "futils";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs = { self, futils, nixpkgs, pre-commit-hooks } @ inputs:
    futils.lib.eachDefaultSystem (system:
      let
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        apps = {
          matrix-notifier =
            futils.lib.mkApp { drv = packages.matrix-notifier; };
        };

        checks = {
          pre-commit = pre-commit-hooks.lib.${system}.run {
            src = ./.;

            hooks = {
              nixpkgs-fmt = {
                enable = true;
              };

              shellcheck = {
                enable = true;
              };
            };
          };
        };

        defaultApp = apps.matrix-notifier;

        defaultPackage = packages.matrix-notifier;

        devShell = pkgs.mkShell {
          name = "matrix-notifier";

          buildInputs = with pkgs; [
            curl
            jq
            shellcheck
          ];

          inherit (self.checks.${system}.pre-commit) shellHook;
        };

        packages = {
          matrix-notifier = pkgs.stdenvNoCC.mkDerivation rec {
            pname = "matrix-notifier";
            version = "0.1.2";

            src = ./matrix-notifier;

            phases = [ "buildPhase" "installPhase" "fixupPhase" ];

            nativeBuildInputs = with pkgs; [
              makeWrapper
              shellcheck
            ];

            buildPhase = ''
              shellcheck $src
            '';

            installPhase = ''
              mkdir -p $out/bin
              cp $src $out/bin/${pname}
              chmod a+x $out/bin/${pname}
            '';

            wrapperPath = with pkgs; lib.makeBinPath [
              curl
              jq
            ];

            fixupPhase = ''
              patchShebangs $out/bin/${pname}
              wrapProgram $out/bin/${pname} --prefix PATH : "${wrapperPath}"
            '';

            meta = with pkgs.lib; {
              description = ''
                A very simple bash script that can be used to send a message to
                a Matrix room
              '';
              homepage = "https://gitea.belanyi.fr/ambroisie/${pname}";
              license = licenses.mit;
              platforms = platforms.unix;
              maintainers = with maintainers; [ ambroisie ];
            };
          };
        };
      }
    );
}
