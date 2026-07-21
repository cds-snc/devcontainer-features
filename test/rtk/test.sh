#!/bin/bash

set -e

source dev-container-features-test-lib

check "rtk version" rtk --version

reportResults
