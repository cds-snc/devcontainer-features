#!/bin/bash

set -e

source dev-container-features-test-lib

check "zizmor version" zizmor --version

reportResults
