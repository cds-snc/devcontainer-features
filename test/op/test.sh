#!/bin/bash

set -e

source dev-container-features-test-lib

check "validate 1password" op --version
check "onepassword-cli group exists" getent group onepassword-cli
check "op binary group ownership" bash -c '[ "$(stat -c "%G" /usr/local/bin/op)" = "onepassword-cli" ]'
check "op binary mode includes setgid" bash -c '[ "$(stat -c "%a" /usr/local/bin/op)" = "2755" ]'

reportResults
