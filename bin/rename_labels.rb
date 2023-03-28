#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  opt :old, "The old label names.", :type => :strings, :required => true
  opt :new, "The new label names.", :type => :strings, :required => true

  MultiRepo::CLI.common_options(self)
end

rename_hash = opts[:old].zip(opts[:new]).to_h
puts "Renaming: #{rename_hash.pretty_inspect}"
puts

MultiRepo.each_repo(**opts) do |repo|
  MultiRepo::Helpers::RenameLabels.new(repo.name, rename_hash, **opts).run
end
