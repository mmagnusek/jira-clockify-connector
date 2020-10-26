require 'curb'
require 'yajl'

class Jira
  include Virtus.model

  JiraApiError = Class.new(Exception)

  attribute :time_entry, TimeEntry

  delegate :user, to: :time_entry

  def execute
    return if time_entry.synced?
    return unless authentication

    if time_entry.jira_id?
      update_worklog
    else
      time_entry.update(jira_id: create_worklog['id'])
    end
    time_entry.touch(:synced_at)
  end

  private

  def authentication
    return false if user.jira_username.blank? || user.jira_password.blank?

    [user.jira_username, user.jira_password].join(':')
  end

  def create_worklog
    new_request do |curl|
      curl.url = "https://#{authentication}@jira.bootiq.io/rest/api/2/issue/#{time_entry.jira_task_id}/worklog"
      curl.http_post(data.to_json)
      raise JiraApiError, curl.body_str unless curl.status.include?('201')
      curl
    end
  end

  def update_worklog
    new_request do |curl|
      curl.url = "https://#{authentication}@jira.bootiq.io/rest/api/2/issue/#{time_entry.jira_task_id}/worklog/#{time_entry.jira_id}"
      curl.http_put(data.to_json)
      raise JiraApiError, curl.body_str unless curl.status.include?('200')
      curl
    end
  end

  def data
    {
      "timeSpentSeconds" => time_entry.duration,
      "started"          => time_entry.start_time.strftime('%FT%T.%L%z'),
      "comment"          => time_entry.jira_task_description.presence || 'Working :-)'
    }
  end

  def new_request
    curl = Curl::Easy.new
    curl.verbose = false
    curl.resolve_mode = :ipv4
    curl.headers['Accept'] = 'application/json'
    curl.headers['Content-Type'] = 'application/json'
    yield(curl)
    Yajl::Parser.new.parse(curl.body_str)
  end
end
