class AddSyncedAtToTimeEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :time_entries, :synced_at, :datetime
  end
end
