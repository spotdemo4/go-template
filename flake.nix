{
  description = "template";

  nixConfig = {
    extra-substituters = [
      "https://cache.trev.zip/nur"
    ];
    extra-trusted-public-keys = [
      "nur:70xGHUW1+1b8FqBchldaunN//pZNVo6FKuPL4U/n844="
    ];
  };

  inputs = {
    systems.url = "systems";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nur = {
      url = "github:spotdemo4/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    semgrep-rules = {
      url = "github:semgrep/semgrep-rules";
      flake = false;
    };
  };

  outputs = {
    nixpkgs,
    utils,
    nur,
    semgrep-rules,
    ...
  }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          nur.overlays.packages
          nur.overlays.libs
        ];
      };
    in {
      devShells = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # go
            go
            gotools
            gopls

            # lint
            golangci-lint
            alejandra
            prettier

            # util
            air
            bumper
          ];
          shellHook = pkgs.shellhook.ref;
        };

        update = pkgs.mkShell {
          packages = with pkgs; [
            renovate
          ];
        };

        vulnerable = pkgs.mkShell {
          packages = with pkgs; [
            # go
            go
            govulncheck

            # nix
            flake-checker
          ];
        };
      };

      checks = pkgs.lib.mkChecks {
        go = {
          src = ./.;
          deps = with pkgs; [
            go
            golangci-lint
            opengrep
          ];
          script = ''
            go test ./...
            golangci-lint run ./...
            opengrep scan --quiet --error --config="${semgrep-rules}/go"
          '';
        };

        nix = {
          src = ./.;
          deps = with pkgs; [
            alejandra
          ];
          script = ''
            alejandra -c .
          '';
        };

        actions = {
          src = ./.;
          deps = with pkgs; [
            prettier
            action-validator
            renovate
          ];
          script = ''
            prettier --check .
            action-validator .github/**/*.yaml
            renovate-config-validator .github/renovate.json
          '';
        };
      };

      packages.default = pkgs.buildGoModule (finalAttrs: {
        pname = "go-template";
        version = "0.1.5";
        src = ./.;
        goSum = ./go.sum;
        vendorHash = null;
        env.CGO_ENABLED = 0;

        meta = {
          description = "template";
          mainProgram = "go-template";
          homepage = "https://github.com/spotdemo4/go-template";
          changelog = "https://github.com/spotdemo4/go-template/releases/tag/v${finalAttrs.version}";
          license = pkgs.lib.licenses.mit;
          platforms = pkgs.lib.platforms.all;
        };
      });

      formatter = pkgs.alejandra;
    });
}
