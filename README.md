# go template

[![check](https://trev.zip/template/go/actions/workflows/check.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=check&labelColor=%23313244)](https://trev.zip/template/go/actions?workflow=check.yaml)
[![vulnerable](https://trev.zip/template/go/actions/workflows/vulnerable.yaml/badge.svg?branch=main&logo=forgejo&logoColor=%23bac2de&label=vulnerable&labelColor=%23313244)](https://trev.zip/template/go/actions?workflow=vulnerable.yaml)
[![nixpkgs](https://nix-shield.trev.zip/?url=https://trev.zip/template/go/raw/branch/main/flake.lock&input=nixpkgs&logoColor=%23bac2de&labelColor=%23313244&color=%235277C3)](https://nixos.org/)
[![go](<https://img.shields.io/badge/dynamic/regex?url=https://trev.zip/template/go/raw/branch/main/go.mod&search=toolchain%20go(.*)&replace=%241&logo=go&logoColor=%23bac2de&label=version&labelColor=%23313244&color=%2300ADD8>)](https://go.dev/doc/devel/release)

template for starting [go](https://go.dev/) projects

to initialize a new project, run:

```sh
./init.sh "Title" "Description"
```

part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## using

### go

```sh
GOPROXY=https://trev.zip/api/packages/template/go \
    go install trev.zip/template/go@latest
```

```sh
go run trev.zip/template/go@latest
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

## contributing

see [CONTRIBUTING.md](CONTRIBUTING.md) for requirements and getting started
