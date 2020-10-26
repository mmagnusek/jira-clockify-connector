require 'curb'
require 'yajl'

class Clockify
  include Virtus.model

  PAGE_SIZE = 100
  TAKS_REGEXP = /\[?([A-Za-z]+-\d+)\]?[\s:]?(.*)/

  ClockifyApiError = Class.new(Exception)
  ClockifyUserNotFoundError = Class.new(Exception)

  attribute :user, User

  def execute
    fetch_time_entries.map do |entry|
      time_entry = user.time_entries.find_or_initialize_by(clockify_id: entry['id'])
      matched    = entry['description'].match(TAKS_REGEXP)

      time_entry.update(
        clockify_description:  entry['description'],
        start_time:            entry['timeInterval']['start'],
        duration:              ActiveSupport::Duration.parse(entry['timeInterval']['duration']),
        jira_task_id:          (matched[1] if matched),
        jira_task_description: (matched[2].strip if matched)
      )
    end
  end

  private

  def fetch_time_entries(page=1)
    params = {
      start: Time.current.beginning_of_month.iso8601,
      end:   Time.current.iso8601,
      page:  page,
      'page-size': PAGE_SIZE
    }
    path = "workspaces/5cd125b9d278ae0c52167416/user/#{user_id}/time-entries?#{params.to_query}"
    time_entries = make_request(path)
    if time_entries.size == PAGE_SIZE
      time_entries + fetch_time_entries(page + 1)
    else
      time_entries.filter { |tm| tm["timeInterval"]["end"] }
    end
  end

  def make_request(path)
    curl = Curl::Easy.new
    curl.verbose = false
    curl.resolve_mode = :ipv4
    curl.headers['X-Api-Key'] = 'X5Z9H4h+NWjrcfjC'
    curl.headers['Content-Type'] = 'application/json'
    curl.url = "https://api.clockify.me/api/v1/#{path}"
    curl.http_get
    raise ClockifyApiError, curl.body_str unless curl.status.include?('200')

    Yajl::Parser.new.parse(curl.body_str)
  end

  def user_id
    unless user.clockify_id
      hash = make_request("workspaces/5cd125b9d278ae0c52167416/users")
      clockify_user = hash.find { |u| u['email'] == user.email }
      user.update(clockify_id: clockify_user['id']) if clockify_user
    end

    user.clockify_id || raise(ClockifyUserNotFoundError, user.email)
  end
end
