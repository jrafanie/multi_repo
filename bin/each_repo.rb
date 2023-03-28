#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  opt :command, "A command to run in each repo", :type => :string, :required => true
  opt :ref, "Ref to checkout before running the command", :type => :string, :default => "master"

  MultiRepo::CLI.common_options(self, :except => :dry_run)
end

MultiRepo.each_repo(**opts) do |r|
  r.fetch
  r.checkout(opts[:ref])
  r.chdir do
    puts "+ #{opts[:command]}"
    system(opts[:command])
  end
end
