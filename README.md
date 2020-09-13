# GoCD development environment in docker

This is development environment for [GoCD](https://github.com/gocd/gocd) built using
[Dojo](https://github.com/ai-traders/dojo) and [official scripts](https://github.com/gocd-contrib/gocd-oss-cookbooks)
used by the CI agents at https://build.gocd.org

This image allows to build and test GoCD. It can be used to **build your fork or locally test a PR**.

# Usage

1. [Install docker](https://docs.docker.com/install/), if you haven't already.
2. Install [Dojo](https://github.com/kudulab/dojo#installation), it is a self-contained binary, so just place it somewhere on the `PATH`. On OSX you can use `brew install kudulab/homebrew-dojo-osx/dojo`.

3. Checkout and `cd` into gocd project directory, then start docker container:
```bash
git clone https://github.com/gocd/gocd.git
cd gocd
dojo
```
This will enter a docker container with all tools needed for building GoCD. Your local copy of gocd is in current directory `/dojo/work`.

In order to build GoCD, you can use `./gradlew`. For example, to build debian packages and generic zip distribution:
```bash
./gradlew clean serverPackageDeb agentPackageDeb agentGenericZip versionFile
```
You will find the artifacts in `installers/target/distributions`.

 * For more details about building GoCD please refer to the [developer documentation](https://developer.gocd.org/current/)
 * For more details about using Dojo see the [readme](https://github.com/ai-traders/dojo)


## License

Copyright 2020 Tomasz Sętkowski

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
