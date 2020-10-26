class User < ApplicationRecord
  has_many :time_entries, dependent: :destroy

  def sync
    Rails.logger.warn('User sync started')
    Clockify.new(user: self).execute
    Rails.logger.warn('User sync: Clockify finished')
    time_entries.where.not(jira_task_id: nil).find_each do |time_entry|
      Jira.new(time_entry: time_entry).execute
    end
    Rails.logger.warn('User sync finished')
  end
end
