# go template

[![check](https://trev.zip/template/go/actions/workflows/check.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://trev.zip/template/go/actions?workflow=check.yaml)
[![vulnerable](https://trev.zip/template/go/actions/workflows/vulnerable.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://trev.zip/template/go/actions?workflow=vulnerable.yaml)
[![nixpkgs](https://img.shields.io/endpoint?url=https%3A%2F%2Fnix-shield.trev.zip%2Fbadge%3Furl%3Dhttps%253A%252F%252Ftrev.zip%252Ftemplate%252Fgo%252Fraw%252Fbranch%252Fmain%252Fflake.lock%26input%3Dnixpkgs&logoColor=%23bac2de&labelColor=%23313244&color=%235277C3)](https://nixos.org/)
[![go](<https://img.shields.io/badge/dynamic/regex?url=https://trev.zip/template/go/raw/branch/main/go.mod&search=toolchain%20go(.*)&replace=%241&logo=go&logoColor=%23bac2de&label=version&labelColor=%23313244&color=%2300ADD8>)](https://go.dev/doc/devel/release)

template for starting [go](https://go.dev/) projects

part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## requirements

- [nix](https://nixos.org/)

## getting started

```sh
nix develop
./init.sh "Title" "Description"
```

### run

```sh
go run .
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
GOPROXY=https://trev.zip/api/packages/template/go \
    go install trev.zip/template/go
```

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
