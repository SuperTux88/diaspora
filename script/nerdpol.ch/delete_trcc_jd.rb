#!/usr/bin/env ruby

# List of spam accounts
accounts = %w(theradiocc@joindiaspora.com)

###########################################################################

# Load diaspora environment
ENV['RAILS_ENV'] ||= "production"
require_relative '../../config/environment'

# Retract all comments of local spammers and close their accounts
Person.where(diaspora_handle: accounts).each do |person|
  AccountDeletion.new(person: person).perform!
end

