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
    trevpkgs = {
      url = "github:spotdemo4/trevpkgs";
      inputs.systems.follows = "systems";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.inputs.systems.follows = "systems";
    };
  };

  outputs =
    {
      self,
      trevpkgs,
      gomod2nix,
      ...
    }:
    trevpkgs.libs.mkFlake (
      system: pkgs: {

        # nix develop [#...]
        devShells = {
          default = pkgs.mkShell {
            shellHook = pkgs.shellhook.ref;
            env.GOTOOLCHAIN = "local";
            packages = with pkgs; [
              # go
              go
              gopls
              gotools
              golangci-lint

              vscode-json-languageserver # json
              yaml-language-server # yaml
              tombi # toml
              oxfmt # format

              # nix
              nixd
              nixfmt

              # util
              treefmt
              bumper
              gomod2nix.packages.${system}.default
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
              go # go mod tidy
              gomod2nix.packages.${system}.default # gomod2nix.toml
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              go
              govulncheck # go
              flake-checker # nix
              zizmor # actions
            ];
          };
        };

        # nix build [#...]
        packages = {
          default = pkgs.mkGoModule (
            final: with pkgs.lib; {
              pname = "go-template";
              version = "0.15.0";

              src = fileset.toSource {
                root = ./.;
                fileset = fileset.unions [
                  ./go.mod
                  ./go.sum
                  (fileset.fileFilter (file: file.hasExt "go") ./.)
                ];
              };
              goSum = ./go.sum;
              modules = ./gomod2nix.toml;

              doCheck = true;
              checkPhase = ''
                runHook preCheck
                go test ./...
                runHook postCheck
              '';

              doInstallCheck = true;
              installCheckPhase = ''
                runHook preInstallCheck
                test "$("$out/bin/${final.meta.mainProgram}")" = "Hello, world!"
                runHook postInstallCheck
              '';

              meta = {
                mainProgram = "go-template";
                description = "go template";
                license = licenses.mit;
                platforms = platforms.all;
                homepage = "https://trev.zip/template/go";
                changelog = "https://trev.zip/template/go/releases";
                downloadPage = "https://trev.zip/template/go/releases/tag/v${final.version}";
              };
            }
          );
        };

        # nix build #images.[...]
        images = {
          default = pkgs.mkImage {
            src = self.packages.${system}.default;
          };
        };

        # nix flake init -t git+https://trev.zip/template/go
        templates = {
          default = {
            path = ./.;
            description = "go template";
            welcomeText = ''
              # go template

              `init.sh` requires a git repository with an `origin` remote:

              ```sh
              git init
              git remote add origin <url>
              bash init.sh "Title" "Description"
              ```
            '';
          };
        };

        # nix fmt
        formatter = pkgs.treefmt.withConfig {
          configFile = ./treefmt.toml;
          runtimeInputs = with pkgs; [
            golangci-lint
            nixfmt
            oxfmt
          ];
        };

        # nix flake check
        checks = pkgs.mkChecks {
          inherit (self.packages.${system}) default;

          go-lint = {
            src = self.packages.${system}.default;
            packages = with pkgs; [ golangci-lint ];
            script = ''
              cp ${./.golangci.yaml} .golangci.yaml
              golangci-lint run ./...
            '';
          };

          nix = {
            root = ./.;
            filter = file: file.hasExt "nix";
            packages = with pkgs; [
              nixfmt
            ];
            script = ''
              nixfmt --check "$file"
            '';
          };

          actions-gh = {
            root = ./.github/workflows;
            filter = file: file.hasExt "yaml";
            packages = with pkgs; [
              action-validator
              zizmor
            ];
            script = ''
              action-validator "$file"
              zizmor --offline "$file"
            '';
          };

          actions-fj = {
            root = ./.forgejo/workflows;
            filter = file: file.hasExt "yaml";
            packages = with pkgs; [
              forgejo-runner
              zizmor
            ];
            script = ''
              forgejo-runner validate --workflow --path "$file"
              zizmor --offline "$file"
            '';
          };

          renovate-gh = {
            root = ./.github;
            files = ./.github/renovate.jsonc;
            packages = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.jsonc
            '';
          };

          renovate-fj = {
            root = ./.forgejo;
            files = ./.forgejo/renovate.jsonc;
            packages = with pkgs; [
              renovate
            ];
            script = ''
              renovate-config-validator renovate.jsonc
            '';
          };

          config = {
            root = ./.;
            filter = file: file.hasExt "json" || file.hasExt "jsonc" || file.hasExt "yaml" || file.hasExt "toml" || file.hasExt "md";
            ignore = ./gomod2nix.toml; # generated
            packages = with pkgs; [
              oxfmt
            ];
            script = ''
              oxfmt --check
            '';
          };
        };
      }
    );
}
