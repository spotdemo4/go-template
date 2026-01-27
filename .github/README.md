# go template

[![check](https://github.com/spotdemo4/go-template/actions/workflows/check.yaml/badge.svg?branch=main)](https://github.com/spotdemo4/go-template/actions/workflows/check.yaml)
[![vulnerable](https://github.com/spotdemo4/go-template/actions/workflows/vulnerable.yaml/badge.svg?branch=main)](https://github.com/spotdemo4/go-template/actions/workflows/vulnerable.yaml)

Template for starting [go](https://go.dev/) projects, part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## Requirements

- [nix](https://nixos.org/)
- (optional) [direnv](https://direnv.net/)

## Getting started

Initialize direnv:

```elm
ln -s .envrc.project .envrc &&
direnv allow
```

or manually enter the development environment:

```elm
nix develop
```

## Run

```elm
nix run #dev
```

## Build

```elm
nix build
```

## Check

```elm
nix flake check
```

## Release

Releases are automatically created for significant changes.

To manually create a new release:

```elm
bumper
```

## Use

### Binary

| OS      | Architecture | Download                                                                                                                                         |
| ------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Linux   | amd64        | [go-template_0.5.7_linux_amd64.tar.gz](https://github.com/spotdemo4/go-template/releases/download/v0.5.7/go-template_0.5.7_linux_amd64.tar.gz)   |
| Linux   | arm64        | [go-template_0.5.7_linux_arm64.tar.gz](https://github.com/spotdemo4/go-template/releases/download/v0.5.7/go-template_0.5.7_linux_arm64.tar.gz)   |
| Linux   | arm          | [go-template_0.5.7_linux_armv6.tar.gz](https://github.com/spotdemo4/go-template/releases/download/v0.5.7/go-template_0.5.7_linux_arm.tar.gz)     |
| MacOS   | arm64        | [go-template_0.5.7_darwin_arm64.tar.gz](https://github.com/spotdemo4/go-template/releases/download/v0.5.7/go-template_0.5.7_darwin_arm64.tar.gz) |
| Windows | amd64        | [go-template_0.5.7_windows_amd64.zip](https://github.com/spotdemo4/go-template/releases/download/v0.5.7/go-template_0.5.7_windows_amd64.zip)     |

more available in [releases](https://github.com/spotdemo4/go-template/releases)

### Docker

```elm
docker run ghcr.io/spotdemo4/go-template:0.5.7
```

### Action

```yaml
- name: go template
  uses: docker://ghcr.io/spotdemo4/go-template:0.5.7
```

### Nix

```elm
nix run github:spotdemo4/go-template
```
