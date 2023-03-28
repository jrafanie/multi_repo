#!/usr/bin/env ruby

require "bundler/inline"
gemfile do
  source "https://rubygems.org"
  gem "multi_repo", require: "multi_repo/cli", path: File.expand_path("..", __dir__)
end

opts = Optimist.options do
  opt :apply, "Apply the `hacktoberfest` label to `good first issue` labels. "\
              "Pass --no-apply to remove the `hacktoberfest` label",
              :type => :boolean, :default => true

  MultiRepo::CLI.common_options(self, :only => :dry_run)
end

class MultiRepo::Hacktoberfest
  attr_reader :apply, :dry_run

  def initialize(apply:, dry_run: false, **_)
    @apply   = apply
    @dry_run = dry_run
  end

  def run
    if apply
      add_hacktoberfest_topics
      good_first_issues.each { |issue| add_hacktoberfest_label(issue) }
    else
      remove_hacktoberfest_topics
      hacktoberfest_issues.each { |issue| remove_hacktoberfest_label(issue) }
    end
  end

  private

  def good_first_issues
    sorted_issues("org:ManageIQ archived:false is:open label:\"good first issue\" -label:hacktoberfest")
  end

  def hacktoberfest_issues
    sorted_issues("org:ManageIQ archived:false is:open label:hacktoberfest")
  end

  def sorted_issues(query)
    github.search_issues(query).items.sort_by { |issue| issue_id(issue) }
  end

  def add_hacktoberfest_label(issue)
    labels = ["hacktoberfest"]
    repo, number = issue_id(issue)
    puts "Adding #{labels.first.inspect} label to issue #{repo}##{number}"

    if dry_run
      puts "** dry_run: github.add_labels_to_an_issue(#{repo.inspect}, #{number.inspect}, #{labels.inspect})"
    else
      github.add_labels_to_an_issue(repo, number, labels)
    end
  end

  def remove_hacktoberfest_label(issue)
    label = "hacktoberfest"
    repo, number = issue_id(issue)
    puts "Removing #{label.inspect} label from issue #{repo}##{number}"

    if dry_run
      puts "** dry_run: github.remove_label(#{repo.inspect}, #{number.inspect}, #{label.inspect})"
    else
      github.remove_label(repo, number, label)
    end
  end

  def add_hacktoberfest_topics
    org_repos.each do |repo|
      add_hacktoberfest_topic(repo)
    end
  end

  def remove_hacktoberfest_topics
    org_repos.each do |repo|
      remove_hacktoberfest_topic(repo)
    end
  end

  def add_hacktoberfest_topic(repo)
    topic  = "hacktoberfest"
    topics = topic_names(repo)
    return if topics.include?(topic)

    puts "Adding #{topic.inspect} topic to repo #{repo}"

    topics << topic
    if dry_run
      puts "** dry_run: github.replace_all_topics(#{repo.inspect}, #{topics.inspect})"
    else
      github.replace_all_topics(repo, topics, :accept => "application/vnd.github.mercy-preview+json")
    end
  end

  def remove_hacktoberfest_topic(repo)
    topic  = "hacktoberfest"
    topics = topic_names(repo)
    return unless topics.include?(topic)

    puts "Removing #{topic.inspect} topic from repo #{repo}"

    topics.delete(topic)
    if dry_run
      puts "** dry_run: github.replace_all_topics(#{repo.inspect}, #{topics.inspect})"
    else
      github.replace_all_topics(repo, topics, :accept => "application/vnd.github.mercy-preview+json")
    end
  end

  def issue_id(issue)
    [issue_repo(issue), issue.number]
  end

  def issue_repo(issue)
    issue.repository_url.split("/").last(2).join("/")
  end

  def topic_names(repo)
    github.topics(repo, :accept => "application/vnd.github.mercy-preview+json")[:names]
  end

  def org_repos
    MultiRepo::Service::Github.client_repo_names_for("ManageIQ")
  end

  def github
    MultiRepo::Service::Github.client
  end
end

MultiRepo::Hacktoberfest.new(opts).run
