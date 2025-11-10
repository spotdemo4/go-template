# go template

![check](https://gitea.com/spotdemo4/go-template/actions/workflows/check.yaml/badge.svg)
![vulnerable](https://gitea.com/spotdemo4/go-template/actions/workflows/vulnerable.yaml/badge.svg)

Template for starting go projects, part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## Requirements

- [nix](https://nixos.org/) package manager
- (optional) [direnv](https://direnv.net/)

## Getting started

Initialize direnv:

```elm
ln -s .envrc.project .envrc &&
direnv allow
```

or enter the dev shell manually:

```elm
nix develop
```

## Running

Run once:

```elm
go run .
```

or run for each change:

```elm
air
```

## Building

```elm
nix build
```

## Checking

```elm
nix flake check
```

## Releasing

Releases are automatically created for significant changes.

To manually create a new release:

```elm
bumper
```
