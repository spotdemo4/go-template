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
              go-tools

              # format
              nixfmt
              tombi
              prettier

              # util
              air
              bumper
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
              govulncheck # go
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
              root = ./.;
              filter = file: file.hasExt "go";
              ignore = fileset.maybeMissing ./vendor;
              include = [
                ./go.mod
                ./go.sum
              ];
              packages = with pkgs; [
                go
                go-tools
              ];
              script = ''
                go test ./...
                go vet ./...
                staticcheck ./...
              '';
            };

            actions = {
              root = ./.;
              files = [
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
              files = ./.github/renovate.json;
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
              ignore = fileset.maybeMissing ./vendor;
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
              ignore = fileset.maybeMissing ./vendor;
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
              ignore = fileset.maybeMissing ./vendor;
              packages = with pkgs; [
                tombi
              ];
              forEach = ''
                tombi format --offline --check "$file"
                tombi lint --offline --error-on-warnings "$file"
              '';
            };
          };

        formatter = pkgs.treefmt.withConfig {
          configFile = ./treefmt.toml;
          runtimeInputs = with pkgs; [
            go
            nixfmt
            tombi
            prettier
          ];
        };

        packages.default = pkgs.buildGoModule (
          final: with pkgs.lib; {
            pname = "go-template";
            version = "0.7.0";

            src = fileset.toSource {
              root = ./.;
              fileset = fileset.unions [
                ./go.mod
                ./go.sum
                (fileset.fileFilter (file: file.hasExt "go") ./.)
                (fileset.maybeMissing ./vendor)
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
              changelog = "https://github.com/spotdemo4/go-template/releases/tag/v${final.version}";
              downloadPage = "https://github.com/spotdemo4/go-template/releases/tag/v${final.version}";
            };
          }
        );

        images.default = pkgs.mkImage {
          src = self.packages.${system}.default;
          contents = with pkgs; [ dockerTools.caCertificates ];
        };

        schemas = trev.schemas;
      }
    );
}
