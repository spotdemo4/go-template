{
  description = "go template";

  nixConfig = {
    extra-substituters = [
      "https://cache.trev.zip/nur"
    ];
    extra-trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
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
            name = "dev";
            shellHook = pkgs.shellhook.ref;
            packages = with pkgs; [
              # go
              go
              gotools
              gopls

              # linters
              revive

              # formatters
              nixfmt
              tombi
              prettier

              # util
              air
              bumper
              flake-release
            ];
          };

          bump = pkgs.mkShell {
            name = "bump";
            packages = with pkgs; [
              bumper
            ];
          };

          release = pkgs.mkShell {
            name = "release";
            packages = with pkgs; [
              flake-release
            ];
          };

          update = pkgs.mkShell {
            name = "update";
            packages = with pkgs; [
              renovate

              # go mod vendor
              go
            ];
          };

          vulnerable = pkgs.mkShell {
            name = "vulnerable";
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
            src = fs.toSource {
              root = ./.;
              fileset = fs.unions [
                ./revive.toml
                (fs.fileFilter (file: file.hasExt "go") ./.)
              ];
            };
            deps = with pkgs; [
              revive
            ];
            script = ''
              revive -set_exit_status ./...
            '';
          };

          actions = {
            src = fs.toSource {
              root = ./.;
              fileset = fs.unions [
                ./action.yaml
                ./.github/workflows
              ];
            };
            deps = with pkgs; [
              action-validator
              octoscan
            ];
            script = ''
              action-validator **/*.yaml
              octoscan scan .
            '';
          };

          renovate = {
            src = fs.toSource {
              root = ./.github;
              fileset = ./.github/renovate.json;
            };
            deps = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.json
            '';
          };

          nix = {
            src = fs.toSource {
              root = ./.;
              fileset = fs.fileFilter (file: file.hasExt "nix") ./.;
            };
            deps = with pkgs; [
              nixfmt-tree
            ];
            script = ''
              treefmt --ci
            '';
          };

          prettier = {
            src = fs.toSource {
              root = ./.;
              fileset = fs.fileFilter (file: file.hasExt "yaml" || file.hasExt "json" || file.hasExt "md") ./.;
            };
            deps = with pkgs; [
              prettier
            ];
            script = ''
              prettier --check .
            '';
          };

          tombi = {
            src = fs.toSource {
              root = ./.;
              fileset = fs.fileFilter (file: file.hasExt "toml") ./.;
            };
            deps = with pkgs; [
              tombi
            ];
            script = ''
              tombi format --offline --check
              tombi lint --offline --error-on-warnings
            '';
          };
        };

        apps = pkgs.lib.mkApps {
          dev.script = "air";
          run.script = "go run .";
        };

        packages = with pkgs.lib; rec {
          default = pkgs.buildGoModule (finalAttrs: {
            pname = "go-template";
            version = "0.5.8";

            src = fs.toSource {
              root = ./.;
              fileset = fs.unions [
                ./go.mod
                ./go.sum
                (fs.fileFilter (file: file.hasExt "go") ./.)
              ];
            };
            goSum = ./go.sum;

            env.CGO_ENABLED = 0;
            vendorHash = null;
            doCheck = false;

            meta = {
              description = "go template";
              mainProgram = "go-template";
              homepage = "https://github.com/spotdemo4/go-template";
              changelog = "https://github.com/spotdemo4/go-template/releases/tag/v${finalAttrs.version}";
              license = licenses.mit;
              platforms = platforms.all;
            };
          });

          image = makeOverridable pkgs.dockerTools.buildLayeredImage {
            name = default.pname;
            tag = default.version;

            contents = with pkgs; [
              dockerTools.caCertificates
            ];

            created = "now";
            meta = default.meta;

            config = {
              Cmd = [ "${meta.getExe default}" ];
              Labels = {
                "org.opencontainers.image.title" = default.pname;
                "org.opencontainers.image.description" = default.meta.description;
                "org.opencontainers.image.version" = default.version;
                "org.opencontainers.image.source" = default.meta.homepage;
                "org.opencontainers.image.licenses" = default.meta.license.spdxId;
              };
            };
          };

          # cross-compilation
          linux-amd64 = default.overrideAttrs (prev: {
            env = prev.env // {
              GOOS = "linux";
              GOARCH = "amd64";
            };
          });
          linux-arm64 = default.overrideAttrs (prev: {
            env = prev.env // {
              GOOS = "linux";
              GOARCH = "arm64";
            };
          });
          linux-arm = default.overrideAttrs (prev: {
            env = prev.env // {
              GOOS = "linux";
              GOARCH = "arm";
            };
          });
          darwin-arm64 = default.overrideAttrs (prev: {
            env = prev.env // {
              GOOS = "darwin";
              GOARCH = "arm64";
            };
          });
          windows-amd64 = default.overrideAttrs (prev: {
            env = prev.env // {
              GOOS = "windows";
              GOARCH = "amd64";
            };
          });

          # images
          linux-amd64-image = image.override (prev: {
            architecture = "amd64";
            config = prev.config // {
              Cmd = [ "${meta.getExe linux-amd64}" ];
            };
          });
          linux-arm64-image = image.override (prev: {
            architecture = "arm64";
            config = prev.config // {
              Cmd = [ "${meta.getExe linux-arm64}" ];
            };
          });
          linux-arm-image = image.override (prev: {
            architecture = "arm";
            config = prev.config // {
              Cmd = [ "${meta.getExe linux-arm}" ];
            };
          });
        };

        formatter = pkgs.nixfmt-tree;
      }
    );
}
