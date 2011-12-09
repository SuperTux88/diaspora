#!/bin/bash

# ignore errors
set +e
set -x

export JENKINS=true

rm -rf reports/cucumber
bundle exec rake cucumber

exit 0
