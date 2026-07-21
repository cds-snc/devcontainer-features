#!/bin/bash

set -e

source dev-container-features-test-lib

check "validate 1password" op --version

reportResults
