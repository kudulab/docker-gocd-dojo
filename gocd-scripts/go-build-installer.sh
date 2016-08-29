#!/bin/bash

set -e

function help_and_exit {
  local usage_prefix="docker run -it -v \`pwd\`/installers:/ide/output gocd-build-installer"
  local usage_prefix_with_env="docker run -it -e REPO=https://github.com/arvindsv/gocd.git -e BRANCH=my_new_feature -v \`pwd\`/installers:/ide/output gocd-build-installer"

  cat <<EOF
[01;31mError: $1[00m

[01;34mUsage: $usage_prefix installer-name [installer-name...][00m
  where each installer-name can be one of:
    win or windows
    osx or mac
    deb or debian
    rpm or redhat or centos
    zip

Example: $usage_prefix deb osx
  to build the Debian and Mac OS X installers.

Options (environment variables):
  REPO   - To configure which git repository should be used. Defaults to https://github.com/gocd/gocd.git.
  BRANCH - To configure which branch to use in that repository. Defaults to master.

Example: $usage_prefix_with_env deb
  to build the Debian installers for my_new_feature branch on the repository mentioned above.
EOF

  exit 1
}

# Installers tasks
# ----------------
# agentGenericZip - Build the go-agent zip installer
# agentOSXZip - Build the go-agent osx package
# agentPackageDeb - Build the go-agent deb package
# agentPackageRpm - Build the go-agent rpm package
# agentWindowsExe - Build the go-agent windows installer
# serverGenericZip - Build the go-server zip installer
# serverOSXZip - Build the go-server osx package
# serverPackageDeb - Build the go-server deb package
# serverPackageRpm - Build the go-server rpm package
# serverWindowsExe - Build the go-server windows installer

# Parse arguments.
declare -a INSTALLERS_NEEDED
while [ "$#" -ge 1 ]; do
  case "$1" in
    win|windows)
      INSTALLERS_NEEDED+=(serverWindowsExe)
      INSTALLERS_NEEDED+=(agentWindowsExe)
      if [ -z ${WINDOWS_JRE_URL+x} ]; then
        echo "Please set WINDOWS_JRE_URL; falling back to mirrors.go.cd";
        export WINDOWS_JRE_URL='https://mirrors.go.cd/local/jre-7u9-windows-i586.tar.gz'
      else
        echo "WINDOWS_JRE_URL='$WINDOWS_JRE_URL'"; fi
      ;;
    osx|mac)
      INSTALLERS_NEEDED+=(serverOSXZip)
      INSTALLERS_NEEDED+=(agentOSXZip)
      ;;
    rpm|redhat|centos)
      INSTALLERS_NEEDED+=(agentPackageRpm)
      INSTALLERS_NEEDED+=(serverPackageRpm)
      ;;
    deb|debian)
      INSTALLERS_NEEDED+=(serverPackageDeb)
      INSTALLERS_NEEDED+=(agentPackageDeb)
      ;;
    zip)
      INSTALLERS_NEEDED+=(agentGenericZip)
      INSTALLERS_NEEDED+=(serverGenericZip)
      ;;
    *)
      help_and_exit "Invalid installer name: $1"
      ;;
  esac

  shift
done

if [ "$(echo "${INSTALLERS_NEEDED[@]}" | grep -q '^$'; echo $?)" = "0" ]; then
  help_and_exit "No installers requested"
fi

export DISABLE_WIN_INSTALLER_LOGGING='true'
export REPO # Used by go-compile.sh
export BRANCH # Used by go-compile.sh

cd /ide/work
$(dirname $0)/go-compile
gradle ${INSTALLERS_NEEDED[@]} versionFile

mkdir -p /ide/output
cp -vR /ide/work/installers/target/distributions/* /ide/output
