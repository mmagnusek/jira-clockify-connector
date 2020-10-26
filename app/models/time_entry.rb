class TimeEntry < ApplicationRecord
  belongs_to :user

  def synced?
    synced_at && synced_at == updated_at
  end
end
