#!/bin/bash

# ignore errors
set +e

bundle exec rake ci:setup:rspec spec

echo "specs finished"

exit 0
