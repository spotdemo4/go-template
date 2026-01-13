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

| OS      | Architecture | Download                                                                                                                                             |
| ------- | ------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------- |
| Linux   | amd64        | [go-template-0.2.0-x86_64-linux.tar.xz](https://github.com/spotdemo4/go-template/releases/download/v0.2.0/go-template-0.2.0-x86_64-linux.tar.xz)     |
| Linux   | arm64        | [go-template-0.2.0-aarch64-linux.tar.xz](https://github.com/spotdemo4/go-template/releases/download/v0.2.0/go-template-0.2.0-aarch64-linux.tar.xz)   |
| Linux   | arm          | [go-template-0.2.0-arm-linux.tar.xz](https://github.com/spotdemo4/go-template/releases/download/v0.2.0/go-template-0.2.0-arm-linux.tar.xz)           |
| MacOS   | arm64        | [go-template-0.2.0-aarch64-darwin.tar.xz](https://github.com/spotdemo4/go-template/releases/download/v0.2.0/go-template-0.2.0-aarch64-darwin.tar.xz) |
| Windows | amd64        | [go-template-0.2.0-x86_64-windows.zip](https://github.com/spotdemo4/go-template/releases/download/v0.2.0/go-template-0.2.0-x86_64-windows.zip)       |

### Docker

```elm
docker run ghcr.io/spotdemo4/go-template:0.2.0
```

### Action

```yaml
- name: go template
  uses: docker://ghcr.io/spotdemo4/go-template:0.2.0
```

### Nix

```elm
nix run github:spotdemo4/go-template
```
