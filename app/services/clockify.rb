class Clockify
  # include Virtus.model

  PAGE_SIZE = 100

  ClockifyApiError = Class.new(Exception)
  ClockifyUserNotFoundError = Class.new(Exception)

  # string :workspace_id
  # string :user_email
  # time :start_time, default: -> { 1.month.ago }
  # time :end_time,   default: -> { Time.now.utc }

  def execute
    fetch_time_entries
  end

  private

  def fetch_time_entries(page=1)
    # params = { start: '2020-10-01T00:00:00+00:00',
    #            end: '2020-10-20T00:00:00+00:00',
    #            page: page,
    #            'page-size': PAGE_SIZE }.to_query
    # path = "workspaces/5cd125b9d278ae0c52167416/user/#{user_id}/time-entries?#{params}"
    path = "workspaces/5cd125b9d278ae0c52167416/user/#{user_id}/time-entries"
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

    # [{"id"=>"5f86aa60ad83f95645469806", "description"=>"CHEDDAR-391", "tagIds"=>nil, "userId"=>"5ce2b589d278ae76b4c5329b", "billable"=>false, "taskId"=>nil, "projectId"=>"5cf4de6db07987371eb9e6f5", "timeInterval"=>{"start"=>"2020-10-14T07:06:00Z", "end"=>"2020-10-14T07:55:04Z", "duration"=>"PT49M4S"}, "workspaceId"=>"5cd125b9d278ae0c52167416", "isLocked"=>false, "customFieldValues"=>nil}]

    Yajl::Parser.new.parse(curl.body_str)
  end

  def user_id
    @user_id ||= begin
      hash = make_request("workspaces/5cd125b9d278ae0c52167416/users")
      user = hash.find { |u| u['email'] == 'magnusekm@gmail.com' }
      raise ClockifyUserNotFoundError, 'magnusekm@gmail.com' unless user
      user['id']
    end
  end
end

puts Clockify.new.execute
