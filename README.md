# GoCD development environment in docker

This is an opinionated development environment for [GoCD](https://github.com/gocd/gocd)
using docker image to pull all required tools.

This image allows to build and partially test gocd. It can be used in CI system
or as a base for developer workstation.

[IDE](https://github.com/ai-traders/ide) stands for Isolated development environment.
This image conforms to *some* of the ideas in IDE project.

## TL;DR

If you have
 * a local docker host
 * the short `ide` [script](https://github.com/ai-traders/ide)

Then you can build [GoCD](https://github.com/gocd/gocd) with

```bash
echo 'IDE_DOCKER_IMAGE="tomzo/gocd-ide:latest"' > Idefile
ide gradle clean prepare fatJar
```

This will pull `tomzo/gocd-ide:latest` image and build GoCD jars in docker.

## Image Content

 * a bunch of useful packages `sudo fakeroot git nsis rpm unzip zip rake wget`
 * `subversion` and `mercurial` for testing SCMs
 * nodejs - needed for server build
 * gradle 3.1 - so that you don't need to wait for gradlew to download
 * minimal ruby setup with `fpm` for packaging

### Build gocd from local workspace

Let's assume `~/code/open/go/gocd` contains a checkout of [gocd](https://github.com/gocd/gocd)
or a fork of it.

Then you can run **any** gocd build command with:
```
docker run -ti --rm -v ~/code/open/go/gocd:/ide/work -v ~:/ide/identity:ro tomzo/gocd-ide COMMAND
```
In non-interactive environments you should skip `-ti` option.

Any compilation or test results will be available locally in
 the mounted directory `~/code/open/go/gocd`

#### Building windows packages

To create windows package bundled oracle jre is used.
You set your own URLs for download with
 * WINDOWS_64BIT_JRE_URL
 * WINDOWS_32BIT_JRE_URL

## Usage with IDE

`gocd` repository should contain `Idefile` with
```
IDE_DOCKER_IMAGE=tomzo/gocd-ide:TAG
```
Thus declaring exact image which is a good enough to build and develop gocd.
