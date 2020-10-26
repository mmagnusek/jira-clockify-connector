class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :email
      t.string :clockify_id
      t.string :jira_username
      t.string :jira_password

      t.timestamps
    end
  end
end
