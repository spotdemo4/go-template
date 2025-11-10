# go-template

![check](https://github.com/spotdemo4/go-template/actions/workflows/check.yaml/badge.svg)
![vulnerable](https://github.com/spotdemo4/go-template/actions/workflows/vulnerable.yaml/badge.svg)

Template for starting go projects, part of [spotdemo4/templates](https://github.com/spotdemo4/templates)

## Getting started

```console
$ ln -s .envrc.project .envrc # create direnv config
$ direnv allow # allow direnv to create dev environment
```

## Running

```console
$ go run . # run once
$ air # run for each change
```

## Building

```console
$ nix build # build for current system
$ nix bundle -o template-linux-arm64 --bundler github:spotdemo4/nur#goToLinuxArm64
```

## Checking

```console
$ go test ./... # run go tests
$ nix flake check # run all checks
```

## Releasing

```console
$ # do nothing, releases are automatically created for significant changes
$ bumper # manually create a new release
```
