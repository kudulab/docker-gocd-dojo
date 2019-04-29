load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

@test "clone gocd" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"rm -rf gocd && git clone --depth 1 https://github.com/gocd/gocd.git\""
  assert_output --partial "Cloning into 'gocd'"
  assert_equal "$status" 0
}

@test "build gocd agent deb package" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"cd gocd && ./gradlew clean agentPackageDeb\""
  assert_equal "$status" 0
}
