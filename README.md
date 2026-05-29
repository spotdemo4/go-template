# go template

[![check](https://trev.zip/template/go/actions/workflows/check.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://trev.zip/template/go/actions?workflow=check.yaml)
[![vulnerable](https://trev.zip/template/go/actions/workflows/vulnerable.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://trev.zip/template/go/actions?workflow=vulnerable.yaml)
[![go](https://img.shields.io/github/go-mod/go-version/spotdemo4/go-template?logo=go&logoColor=%23bac2de&label=version&labelColor=%23313244&color=%2300ADD8)](https://go.dev/doc/devel/release)

template for starting [go](https://go.dev/) projects

part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## requirements

- [nix](https://nixos.org/)

## getting started

```sh
nix develop
```

### run

```sh
nix run #dev
```

### format

```sh
nix fmt
```

### check

```sh
nix flake check
```

### build

```sh
nix build
```

### release

```sh
bumper
```

releases are automatically created for [significant](https://www.conventionalcommits.org/en/v1.0.0/#summary) changes

## use

### go

```sh
go run trev.zip/template/go
```

### docker

```sh
docker run trev.zip/template/go:latest
```

### nix

```sh
nix run git+https://trev.zip/template/go.git
```

### download

https://trev.zip/template/go/releases
