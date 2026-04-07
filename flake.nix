{
  description = "go template";

  nixConfig = {
    extra-substituters = [
      "https://nix.trev.zip"
    ];
    extra-trusted-public-keys = [
      "trev:I39N/EsnHkvfmsbx8RUW+ia5dOzojTQNCTzKYij1chU="
    ];
  };

  inputs = {
    systems.url = "github:spotdemo4/systems";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    trev = {
      url = "github:spotdemo4/nur";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      trev,
      ...
    }:
    trev.libs.mkFlake (
      system: pkgs: {
        devShells = {
          default = pkgs.mkShell {
            shellHook = pkgs.shellhook.ref;
            packages = with pkgs; [
              # go
              go
              gotools
              gopls

              # lint
              revive

              # format
              nixfmt
              tombi
              prettier

              # util
              air
              bumper
              flake-release
              renovate
            ];
          };

          bump = pkgs.mkShell {
            packages = with pkgs; [
              bumper
            ];
          };

          release = pkgs.mkShell {
            packages = with pkgs; [
              flake-release
            ];
          };

          update = pkgs.mkShell {
            packages = with pkgs; [
              renovate
              go # go mod vendor
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              # go
              go
              govulncheck
              flake-checker # nix
              octoscan # actions
            ];
          };
        };

        apps = pkgs.mkApps {
          dev = "air";
          run = "go run .";
          vendor = "go mod tidy && go mod vendor";
        };

        checks =
          with pkgs.lib;
          pkgs.mkChecks {
            go = {
              src = self.packages.${system}.default;
              script = ''
                go test ./...
              '';
            };

            revive = {
              root = ./.;
              fileset = fileset.unions [
                ./revive.toml
                (fileset.fileFilter (file: file.hasExt "go") ./.)
              ];
              packages = with pkgs; [
                revive
              ];
              script = ''
                revive ./...
              '';
            };

            actions = {
              root = ./.;
              fileset = fileset.unions [
                ./action.yaml
                ./.github/workflows
              ];
              packages = with pkgs; [
                action-validator
                octoscan
              ];
              forEach = ''
                action-validator "$file"
                octoscan scan "$file"
              '';
            };

            renovate = {
              root = ./.github;
              fileset = ./.github/renovate.json;
              packages = with pkgs; [
                renovate
              ];
              script = ''
                renovate-config-validator renovate.json
              '';
            };

            nix = {
              root = ./.;
              filter = file: file.hasExt "nix";
              packages = with pkgs; [
                nixfmt
              ];
              forEach = ''
                nixfmt --check "$file"
              '';
            };

            prettier = {
              root = ./.;
              filter = file: file.hasExt "yaml" || file.hasExt "json" || file.hasExt "md";
              packages = with pkgs; [
                prettier
              ];
              forEach = ''
                prettier --check "$file"
              '';
            };

            tombi = {
              root = ./.;
              filter = file: file.hasExt "toml";
              packages = with pkgs; [
                tombi
              ];
              forEach = ''
                tombi format --offline --check "$file"
                tombi lint --offline --error-on-warnings "$file"
              '';
            };
          };

        packages =
          with pkgs.lib;
          pkgs.mkPackages pkgs (pkgs: {
            default = pkgs.buildGoModule (finalAttrs: {
              pname = "go-template";
              version = "0.6.1";

              src = fileset.toSource {
                root = ./.;
                fileset = fileset.unions [
                  ./go.mod
                  ./go.sum
                  (fileset.maybeMissing ./vendor)
                  (fileset.fileFilter (file: file.hasExt "go") ./.)
                ];
              };
              goSum = ./go.sum;
              vendorHash = null;

              meta = {
                mainProgram = "go-template";
                description = "go template";
                license = licenses.mit;
                platforms = platforms.all;
                homepage = "https://github.com/spotdemo4/go-template";
                changelog = "https://github.com/spotdemo4/go-template/releases/tag/v${finalAttrs.version}";
                downloadPage = "https://github.com/spotdemo4/go-template/releases/tag/v${finalAttrs.version}";
              };
            });
          });

        images = pkgs.mkImages pkgs (pkgs: {
          default = pkgs.mkImage self.packages.${system}.default {
            contents = with pkgs; [ dockerTools.caCertificates ];
          };
        });

        formatter = pkgs.nixfmt-tree;
        schemas = trev.schemas;
      }
    );
}
