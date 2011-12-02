#!/bin/bash

cp config/ci/jenkins/application.yml config/application.yml
cp config/ci/jenkins/database.yml config/database.yml

# install missing gems
bundle install

echo "Regenerating CSS files"
bundle exec sass -q --update public/stylesheets/sass/:public/stylesheets/

bundle exec rake db:drop
bundle exec rake db:create
bundle exec rake db:schema:load
