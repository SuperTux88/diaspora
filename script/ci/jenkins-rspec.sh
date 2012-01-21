#!/bin/bash

# ignore errors
set +e
set -x

export CI_REPORTS=spec/reports_fixtures
bundle exec rake ci:setup:rspec generate_fixtures

unset CI_REPORTS
bundle exec rake ci:setup:rspec spec

exit 0
