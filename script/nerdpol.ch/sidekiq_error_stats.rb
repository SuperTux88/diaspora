#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= "production"
require_relative "../../config/environment"
require "terminal-table"

def count_errors(set)
  set.map {|job| job.item["error_class"] }
     .each_with_object(Hash.new(0)) {|error, counts| counts[error] += 1 }
     .sort_by {|_, count| count }.reverse
end

def dump_table(title, set)
  puts
  puts Terminal::Table.new title: title, headings: %w(Error Count), rows: set
end

def dump_error_details(title, set, error_class)
  puts
  puts "Set: #{title} | Error: #{error_class}"
  set.select {|job| job.item["error_class"] == error_class }
     .each do |job|
    puts "================================================="
    puts "jid: #{job.item['jid']}"
    puts "error_message: #{job.item['error_message']}"
    puts "error_backtrace:\n  #{job.item['error_backtrace'].join("\n  ")}"
  end
end

def dump_jid_details(set, jid)
  set.find {|job| job.item["jid"] == jid }
     .try do |job|
    puts "jid: #{job.item['jid']}"
    puts "class: #{job.item['class']}"
    puts "args:"
    pp job.item["args"]
    puts "error_class: #{job.item['error_class']}"
    puts "error_message: #{job.item['error_message']}"
    puts "error_backtrace:\n  #{job.item['error_backtrace'].join("\n  ")}"
  end
end

if ARGV.empty?
  dump_table("Retries", count_errors(Sidekiq::RetrySet.new))
  dump_table("Dead", count_errors(Sidekiq::DeadSet.new))
elsif ARGV.length == 2 && ARGV[0] == "--error_class"
  dump_error_details("Retries", Sidekiq::RetrySet.new, ARGV[1])
  dump_error_details("Dead", Sidekiq::DeadSet.new, ARGV[1])
elsif ARGV.length == 2 && ARGV[0] == "--jid"
  dump_jid_details(Sidekiq::RetrySet.new, ARGV[1])
  dump_jid_details(Sidekiq::DeadSet.new, ARGV[1])
else
  puts "Usage:"
  puts "Statistics: sidekiq_error_stats.rb"
  puts "Error class details: sidekiq_error_stats.rb --error_class ErrorClass"
  puts "Print jid details: sidekiq_error_stats.rb --jid jid"
end
