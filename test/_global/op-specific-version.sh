#!/bin/bash

set -e
source dev-container-features-test-lib
check "op with specific version" /bin/bash -c "op --version | grep '2.35.0'"
reportResults
