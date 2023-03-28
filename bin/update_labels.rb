#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  MultiRepo::CLI.common_options(self, :repo_set_default => nil)
end
opts[:repo] = MultiRepo::Labels.all.keys.sort unless opts[:repo] || opts[:repo_set]

MultiRepo.each_repo(opts) do |repo|
  MultiRepo::Helpers::UpdateLabels.new(repo.name, **opts).run
end
