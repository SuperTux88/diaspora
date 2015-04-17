class CommitsController < ApplicationController
  def receive
    payload = JSON.parse(params[:payload])

    post_message build_message(payload) unless payload['commits'].empty?

    render nothing: true, status: 201
  rescue JSON::ParserError, ActiveRecord::RecordInvalid
    render nothing: true, status: 422
  end

  private

  def build_message payload
    branch = payload['ref'].gsub "refs/heads/", ""
    repository = payload['repository']['name']
    repository_url = payload['repository']['url']
    message_lines = []
    message_lines << "New push to **#{branch}** at [#{repository.capitalize}](#{repository_url})" << ""

    payload['commits'].reverse.each do |commit|
      first_line, *commit_lines = commit['message'].strip.split("\n")

      message_lines << "* [Commit](#{commit['url']}): #{first_line} by *#{commit['author']['name']}*"
      message_lines.concat commit_lines.map {|line| "  #{line}" }
    end

    message_lines << ""
    message_lines << "##{repository}_push ##{repository}_#{branch.gsub("/", "_")}_push"

    convert_issue_links message_lines.join("\n")
  end

  def convert_issue_links message
    message.gsub(/#(\d+)/) do |match|
      "[#{$1}](https://github.com/diaspora/diaspora/issues/#{$1})"
    end
  end

  def post_message message
    user = User.where(id: 511).first
    post = user.build_post(:status_message,
                           public: true,
                           text: message,
                           aspect_ids: user.aspect_ids
    )
    post.save!
    user.add_to_streams(post, user.aspects)
    user.dispatch_post(post, url: short_post_url(post.guid))
  end
end
