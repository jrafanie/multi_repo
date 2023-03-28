#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  opt :branch, "The branch to destroy.", :type => :string, :required => true

  MultiRepo::CLI.common_options(self, :except => :dry_run)
end

MultiRepo.each_repo(opts) do |repo|
  repo.chdir do
    system("git checkout master")
    system("git branch -D #{opts[:branch]}")
  end
end
