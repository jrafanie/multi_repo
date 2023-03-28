#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  opt :owners, "Owners to add to the gem stub", :type => :strings, :default => []

  MultiRepo::CLI.common_options(self, :except => :repo_set)
end

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::Service::RubygemsStub.new(repo.name, opts).run
end
