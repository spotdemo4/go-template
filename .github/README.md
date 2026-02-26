# go template

[![check](https://img.shields.io/github/actions/workflow/status/spotdemo4/go-template/check.yaml?branch=main&logo=github&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://github.com/spotdemo4/go-template/actions/workflows/check.yaml/)
[![vulnerable](https://img.shields.io/github/actions/workflow/status/spotdemo4/go-template/vulnerable.yaml?branch=main&logo=github&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://github.com/spotdemo4/go-template/actions/workflows/vulnerable.yaml)
[![nix](https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fraw.githubusercontent.com%2Fspotdemo4%2Fgo-template%2Frefs%2Fheads%2Fmain%2Fflake.lock&query=%24.nodes.nixpkgs.original.ref&logo=nixos&logoColor=%23bac2de&label=channel&labelColor=%23313244&color=%234d6fb7)](https://nixos.org/)
[![go](https://img.shields.io/github/go-mod/go-version/spotdemo4/go-template?logo=go&logoColor=%23bac2de&label=version&labelColor=%23313244&color=%2300ADD8)](https://go.dev/doc/devel/release)
[![flakehub](https://img.shields.io/endpoint?url=https://flakehub.com/f/spotdemo4/go-template/badge&labelColor=%23313244)](https://flakehub.com/flake/spotdemo4/go-template)

template for starting [Go](https://go.dev/) projects

part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## requirements

- [nix](https://nixos.org/)
- [direnv](https://direnv.net/) (optional)

## getting started

initialize direnv:

```elm
ln -s .envrc.project .envrc &&
direnv allow
```

or manually enter the development environment:

```elm
nix develop
```

### run

```elm
nix run #dev
```

### build

```elm
nix build
```

### check

```elm
nix flake check
```

### release

releases are automatically created for [significant](https://www.conventionalcommits.org/en/v1.0.0/#summary) changes

to manually create a version bump:

```elm
bumper action.yaml .github/README.md
```

## use

### download

| OS      | Architecture | Download                                                                                                                                     |
| ------- | ------------ | -------------------------------------------------------------------------------------------------------------------------------------------- |
| Linux   | amd64        | [go-template_0.5.8_linux_amd64.xz](https://github.com/spotdemo4/go-template/releases/download/v0.5.8/go-template_0.5.8_linux_amd64.xz)       |
| Linux   | arm64        | [go-template_0.5.8_linux_arm64.xz](https://github.com/spotdemo4/go-template/releases/download/v0.5.8/go-template_0.5.8_linux_arm64.xz)       |
| Linux   | arm          | [go-template_0.5.8_linux_arm.xz](https://github.com/spotdemo4/go-template/releases/download/v0.5.8/go-template_0.5.8_linux_arm.xz)           |
| MacOS   | arm64        | [go-template_0.5.8_darwin_arm64.xz](https://github.com/spotdemo4/go-template/releases/download/v0.5.8/go-template_0.5.8_darwin_arm64.xz)     |
| Windows | amd64        | [go-template_0.5.8_windows_amd64.zip](https://github.com/spotdemo4/go-template/releases/download/v0.5.8/go-template_0.5.8_windows_amd64.zip) |

### docker

```elm
docker run ghcr.io/spotdemo4/go-template:0.5.8
```

### action

```yaml
- name: go template
  uses: spotdemo4/go-template@v0.5.8
```

### nix

```elm
nix run github:spotdemo4/go-template
```
