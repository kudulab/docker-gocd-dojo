load '/opt/bats-support/load.bash'
load '/opt/bats-assert/load.bash'

@test "/usr/bin/entrypoint.sh returns 0" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"pwd && whoami\""
  # this is printed on test failure
  echo "output: $output"
  assert_output --partial "dojo init finished"
  assert_output --partial "/dojo/work"
  assert_output --partial "gocd-dojo"
  refute_output --partial "root"
  assert_equal "$status" 0
}

@test "ssh keys get copied" {
  run /bin/bash -c "dojo -c Dojofile.to_be_tested \"cat ~/.ssh/id_rsa\""
  # this is printed on test failure
  echo "output: $output"
  assert_output --partial "inside id_rsa"
  assert_equal "$status" 0
}
