# go template

![check](https://github.com/spotdemo4/go-template/actions/workflows/check.yaml/badge.svg?branch=main)
![vulnerable](https://github.com/spotdemo4/go-template/actions/workflows/vulnerable.yaml/badge.svg?branch=main)

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

| OS      | Architecture | Download                                                                                                            |
| ------- | ------------ | ------------------------------------------------------------------------------------------------------------------- |
| Linux   | x86_64       | [tar.xz](https://github.com/spotdemo4/go-template/releases/download/v0.1.7/go-template-0.1.7-x86_64-linux.tar.xz)   |
| Linux   | aarch64      | [tar.xz](https://github.com/spotdemo4/go-template/releases/download/v0.1.7/go-template-0.1.7-aarch64-linux.tar.xz)  |
| MacOS   | aarch64      | [tar.xz](https://github.com/spotdemo4/go-template/releases/download/v0.1.7/go-template-0.1.7-aarch64-darwin.tar.xz) |
| Windows | x86_64       | [zip](https://github.com/spotdemo4/go-template/releases/download/v0.1.7/go-template-0.1.7-x86_64-windows.zip)       |

### Docker

```elm
docker run ghcr.io/spotdemo4/go-template:0.1.7
```

### Nix

```elm
nix run github:spotdemo4/go-template
```
