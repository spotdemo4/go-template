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
            shellHook = pkgs.trev.shellhook.ref;
            env.GOTOOLCHAIN = "local";
            packages = with pkgs; [
              # go
              trev.go-latest
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
              trev.bumper
              gomod2nix.packages.${system}.default
            ];
          };

          bump = pkgs.mkShell {
            packages = with pkgs; [
              trev.bumper
            ];
          };

          release = pkgs.mkShell {
            packages = with pkgs; [
              trev.flake-release
            ];
          };

          update = pkgs.mkShell {
            packages = with pkgs; [
              trev.renovate
              trev.go-latest # go mod tidy
            ];
          };

          vulnerable = pkgs.mkShell {
            packages = with pkgs; [
              trev.go-latest
              govulncheck # go
              flake-checker # nix
              zizmor # actions
            ];
          };
        };

        # nix run [#...]
        apps = pkgs.trev.libs.mkApps {
          update-deps = {
            packages = with pkgs; [
              trev.go-latest
              gomod2nix.packages.${system}.default
            ];
            script = ''
              go mod tidy
              gomod2nix generate --with-deps
            '';
          };
        };

        # nix build [#...]
        packages = {
          default = pkgs.trev.libs.mkGoModule (
            final: with pkgs.lib; {
              pname = "go-template";
              version = "0.21.0";

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
                downloadPage = "https://trev.zip/template/go/releases";
                changelog = "https://trev.zip/template/go/releases/tag/v${final.version}";
                sourceProvenance = [ sourceTypes.fromSource ];
                maintainers = [ maintainers.spotdemo4 ];
              };
            }
          );
        };

        # nix build #images.[...]
        images = {
          default = pkgs.trev.libs.mkImage {
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
        checks = pkgs.trev.libs.mkChecks {
          go-lint = {
            src = self.packages.${system}.default;
            packages = with pkgs; [ golangci-lint ];
            script = ''
              cp ${./.golangci.yaml} .golangci.yaml
              golangci-lint run ./...
            '';
          };

          # go.mod's toolchain line can't be newer than the go that builds the package
          go-toolchain = {
            root = ./.;
            files = ./go.mod;
            packages = with pkgs; [
              self.packages.${system}.default.passthru.go
              jq
            ];
            script = ''
              export GOTOOLCHAIN=local
              toolchain=$(go mod edit -json | jq -r '.Toolchain // empty')
              version=$(go env GOVERSION)
              if [[ -n "$toolchain" && "$(printf '%s\n' "$toolchain" "$version" | sort -V | tail -n 1)" != "$version" ]]; then
                echo "go.mod's toolchain line is $toolchain, but the package is built with $version" >&2
                echo "run 'nix flake update trevpkgs' once trevpkgs' go-latest has $toolchain" >&2
                exit 1
              fi
            '';
          };

          init = {
            root = ./.;
            packages = with pkgs; [
              git
              trev.go-latest
              jq
              shellcheck
              self.formatter.${system}
            ];
            script = ''
              shellcheck init.sh init.test.sh
              bash init.test.sh
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

          actions-gt = {
            root = ./.gitea/workflows;
            filter = file: file.hasExt "yaml";
            packages = with pkgs; [
              action-validator
              gitea-actions-runner
              zizmor
            ];
            script = ''
              gitea-runner exec --list --workflows "$file"
              action-validator "$file"
              zizmor --offline "$file"
            '';
          };

          renovate-gh = {
            root = ./.github;
            files = ./.github/renovate.jsonc;
            packages = with pkgs; [
              trev.renovate
            ];
            script = ''
              renovate-config-validator renovate.jsonc
            '';
          };

          renovate-fj = {
            root = ./.forgejo;
            files = ./.forgejo/renovate.jsonc;
            packages = with pkgs; [
              trev.renovate
            ];
            script = ''
              renovate-config-validator renovate.jsonc
            '';
          };

          renovate-gt = {
            root = ./.gitea;
            files = ./.gitea/renovate.jsonc;
            packages = with pkgs; [
              trev.renovate
            ];
            script = ''
              renovate-config-validator renovate.jsonc
            '';
          };

          config = {
            root = ./.;
            filter =
              file:
              file.hasExt "json"
              || file.hasExt "jsonc"
              || file.hasExt "yaml"
              || file.hasExt "toml"
              || file.hasExt "md";
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
