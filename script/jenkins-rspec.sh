#!/bin/bash

# ignore errors
set +e
set -x

export CI_REPORTS=reports/fixtures
bundle exec rake ci:setup:rspec generate_fixtures

export CI_REPORTS=reports/specs
bundle exec rake ci:setup:rspec spec

exit 0
