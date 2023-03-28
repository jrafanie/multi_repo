#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  opt :tag, "The tag to destroy", :type => :string, :required => true

  MultiRepo::CLI.common_options(self, :except => :dry_run, :repo_set_default => nil)
end
opts[:repo_set] = opts[:tag].split("-").first unless opts[:repo] || opts[:repo_set]

post_review = StringIO.new

MultiRepo.each_repo(opts) do |repo|
  next if repo.config.has_real_releases || repo.config.skip_tag

  destroy_tag = MultiRepo::Helpers::DestroyTag.new(repo, opts)
  destroy_tag.run
  post_review.puts(destroy_tag.post_review)
end

puts
puts "Run the following script to delete '#{opts[:tag]}' tag from all remote repos"
puts
puts post_review.string
