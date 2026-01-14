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
    systems.url = "github:nix-systems/default";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    trev = {
      url = "github:spotdemo4/nur";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    semgrep-rules = {
      url = "github:semgrep/semgrep-rules";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      trev,
      semgrep-rules,
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
      in
      rec {
        devShells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              # go
              go
              gotools
              gopls
              revive
              goreleaser

              # util
              air
              bumper

              # nix
              nixfmt

              # actions
              prettier
            ];
            shellHook = pkgs.shellhook.ref;
          };

          bump = pkgs.mkShell {
            packages = with pkgs; [
              bumper
            ];
          };

          release = pkgs.mkShell {
            packages = with pkgs; [
              go
              goreleaser
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
            deps = with pkgs; [
              revive
              goreleaser
              opengrep
            ];
            script = ''
              go test ./...
              revive -config revive.toml -set_exit_status ./...
              goreleaser check
              opengrep scan \
                --quiet \
                --error \
                --use-git-ignore \
                --exclude="/vendor/" \
                --config="${semgrep-rules}/go"
            '';
          };

          nix = {
            src = ./.;
            deps = with pkgs; [
              nixfmt-tree
            ];
            script = ''
              treefmt --ci
            '';
          };

          actions = {
            src = ./.;
            deps = with pkgs; [
              prettier
              action-validator
              octoscan
              renovate
            ];
            script = ''
              prettier --check .
              action-validator .github/**/*.yaml
              octoscan scan .github
              renovate-config-validator .github/renovate.json
            '';
          };
        };

        apps = pkgs.lib.mkApps {
          dev.script = "air";
          run.script = "go run .";
        };

        packages.default = pkgs.buildGoModule (finalAttrs: {
          pname = "go-template";
          version = "0.2.1";

          src = builtins.path {
            name = "root";
            path = ./.;
          };
          goSum = finalAttrs.src + "go.sum";
          vendorHash = null;
          env.CGO_ENABLED = 0;

          meta = {
            description = "go template";
            mainProgram = "go-template";
            homepage = "https://github.com/spotdemo4/go-template";
            changelog = "https://github.com/spotdemo4/go-template/releases/tag/v${finalAttrs.version}";
            license = pkgs.lib.licenses.mit;
            platforms = pkgs.lib.platforms.all;
          };
        });

        formatter = pkgs.nixfmt-tree;
      }
    );
}
