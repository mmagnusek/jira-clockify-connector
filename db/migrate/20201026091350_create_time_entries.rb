class CreateTimeEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :time_entries do |t|
      t.belongs_to :user
      t.string     :clockify_id
      t.string     :clockify_description
      t.integer    :jira_id
      t.string     :jira_task_id
      t.string     :jira_task_description
      t.datetime   :start_time
      t.bigint     :duration

      t.timestamps
    end
  end
end
