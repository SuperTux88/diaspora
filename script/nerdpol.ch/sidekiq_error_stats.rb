#!/usr/bin/env ruby

ENV['RAILS_ENV'] ||= "production"
require_relative "../config/environment"
require "terminal-table"

def count_errors(set)
   set.map { |job| job.item["error_class"] }.each_with_object(Hash.new(0)) { |error, counts| counts[error] += 1 }.sort_by { |error, count| count }.reverse
end

def dump_table(title, set)
  puts
  puts Terminal::Table.new title: title, headings: %w(Error Count), rows: set
end

dump_table "Retries", count_errors(Sidekiq::RetrySet.new)
dump_table "Dead", count_errors(Sidekiq::DeadSet.new)
