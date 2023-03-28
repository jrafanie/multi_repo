#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  MultiRepo::CLI.common_options(self)
end

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::Helpers::UpdateRepoSettings.new(repo.name, **opts).run
end
