#!/bin/bash

# ignore errors
set +e
set -x

export JENKINS=true

rm -rf features/reports
bundle exec rake cucumber

export GROUP=oauth
bundle exec rake cucumber

exit 0
