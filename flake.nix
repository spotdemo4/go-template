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
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    trev = {
      url = "github:spotdemo4/nur";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      trev,
      ...
    }:
    trev.libs.mkFlake (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            trev.overlays.packages
            trev.overlays.libs
          ];
        };
        fs = pkgs.lib.fileset;
      in
      rec {
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

              # go mod vendor
              go
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              # go
              go
              govulncheck

              # nix
              flake-checker

              # actions
              octoscan
            ];
          };
        };

        checks = pkgs.lib.mkChecks {
          go = {
            src = packages.default;
            script = ''
              go test ./...
            '';
          };

          revive = {
            root = ./.;
            fileset = fs.unions [
              ./revive.toml
              (fs.fileFilter (file: file.hasExt "go") ./.)
            ];
            deps = with pkgs; [
              revive
            ];
            script = ''
              revive -set_exit_status ./...
            '';
          };

          actions = {
            root = ./.;
            fileset = fs.unions [
              ./action.yaml
              ./.github/workflows
            ];
            deps = with pkgs; [
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
            deps = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            deps = with pkgs; [
              nixfmt
            ];
            forEach = ''
              nixfmt --check "$file"
            '';
          };

          prettier = {
            root = ./.;
            filter = file: file.hasExt "yaml" || file.hasExt "json" || file.hasExt "md";
            deps = with pkgs; [
              prettier
            ];
            forEach = ''
              prettier --check "$file"
            '';
          };

          tombi = {
            root = ./.;
            filter = file: file.hasExt "toml";
            deps = with pkgs; [
              tombi
            ];
            forEach = ''
              tombi format --offline --check "$file"
              tombi lint --offline --error-on-warnings "$file"
            '';
          };
        };

        apps = pkgs.lib.mkApps {
          dev.script = "air";
          run.script = "go run .";
          vendor.script = "go mod tidy && go mod vendor";
        };

        packages = pkgs.lib.mkPackages (target: {
          default = target.buildGoModule (finalAttrs: {
            pname = "go-template";
            version = "0.6.0";

            src = fs.toSource {
              root = ./.;
              fileset = fs.unions [
                ./go.mod
                ./go.sum
                (fs.maybeMissing ./vendor)
                (fs.fileFilter (file: file.hasExt "go") ./.)
              ];
            };
            goSum = ./go.sum;
            vendorHash = null;

            meta = {
              description = "go template";
              mainProgram = "go-template";
              homepage = "https://github.com/spotdemo4/go-template";
              changelog = "https://github.com/spotdemo4/go-template/releases/tag/v${finalAttrs.version}";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.all;
            };
          });
        });

        images = pkgs.lib.mkImages (target: {
          default = target.mkImage packages.default {
            contents = with target; [ dockerTools.caCertificates ];
          };
        });

        schemas = trev.schemas;
        formatter = pkgs.nixfmt-tree;
      }
    );
}
