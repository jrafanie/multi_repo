#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  MultiRepo::CLI.common_options(self, :only => :dry_run)
end

github = MultiRepo::Service::Github.new(**opts.slice(:dry_run))

repos = (github.org_repo_names("ManageIQ") << "ManageIQ/rbvmomi2").sort
repos.each do |repo_name|
  puts MultiRepo.header(repo_name)

  disabled_workflows = github.disabled_workflows
  if disabled_workflows.any?
    disabled_workflows.each do |w|
      puts "** Enabling #{w.html_url} (#{w.id})"
      github.enable_workflow(github, repo_name, w.html_url, w.id)
    end
  else
    puts "** No disabled workflows found"
  end

  puts
end
