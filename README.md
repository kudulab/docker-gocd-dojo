# gocd isolated development environment

This is an opinionated development environment for [gocd](https://github.com/gocd/gocd)
using docker image to pull all required tools.

Most gocd scripts are based on [gocd-docker](https://github.com/gocd/gocd-docker)

This image allows to build and partially test gocd. It can be used in CI system
or as a base for developer workstation.

This is also a very early preview of the generic IDE concept that we are working on.
It aims to standardize executing build system jobs in docker containers.
That's why some paths, users and scripts may seem a little weird.

## Usage with bare docker

There are use cases for this image.

 * build gocd from local working copy
 * build an ad-hoc commit from remote git repository and branch.

Local copy works best for long-term development.

These scripts are available to execute common go tasks:
 * `/usr/bin/go-compile` - compiles sources in `/ide/work`. You can also use
 environment variables to first checkout a remote source.
 * `/usr/bin/go-build-installer` - compiles sources and builds packages in `/ide/work`

#### Identity

In commands below you can find `/ide/identity` mount. It is only required
 * if you need ssh (git over ssh) access, or
 * you will be committing to gocd git repository. `~/.gitconfig` is needed then.

### Build gocd from local workspace

Let's assume `~/code/gocd` contains a checkout of [gocd](https://github.com/gocd/gocd)
or a fork of it.

Then you can run **any** gocd build command with:
```
docker run -ti --rm -v ~/code/gocd:/ide/work -v ~:/ide/identity:ro tomzo/gocd-ide COMMAND
```
In non-interactive environments you should skip `-ti` option.

Any compilation or test results will be available locally in
 the mounted directory `~/code/gocd`

### Build from remote git sources

There are 3 environment variables you can use:

 * `REPO`   - you should always set it. e.g. https://github.com/tomzo/gocd.git
 * `BRANCH` - default is master. e.g. develop
 * `COMMIT` - any commit in format that `git` CLI accepts. There is no default.

You should skip mounting local volume with `-v ~/code/gocd:/ide/work`

You can run build commands with
```
docker run -ti --rm -v ~:/ide/identity:ro -v `pwd`/gocd-output:/ide/output tomzo/gocd-ide COMMAND
```

Specifically you can build all debian and windows packages with
```
docker run -ti --rm -v ~:/ide/identity:ro -v `pwd`/gocd-output:/ide/output tomzo/gocd-ide \
-e REPO=git@github.com:gocd/gocd.git \
-e BRANCH=develop \
-e COMMIT=000fc0f7c60902dd05699a182310cfe4690b059c \
go-build-installer deb win
```

The build outputs will be available in `/ide/output` in the container so it should
be mounted from host. In case you don't want to mount output there is always `docker cp`.
Just skip `--rm` option to keep container after run and you can run 3 commands like this:
```
docker run --name gocd-ide [options and commands]
docker cp gocd-ide:/ide/output local-dir
docker rm gocd-ide
```

#### Building windows

To create windows package `WINDOWS_JRE_LOCATION` must be set.

## Usage with IDE

`gocd` repository should contain `IdeFile` with
```
IDE_DOCKER_IMAGE=tomzo/gocd-ide:TAG
```
Thus declaring exact image which is a good enough to build and develop gocd.

### Building local workspace

```
ide go-build-installer deb win
```
