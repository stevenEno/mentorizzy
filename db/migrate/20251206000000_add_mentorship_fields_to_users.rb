class AddMentorshipFieldsToUsers < ActiveRecord::Migration[8.2]
  def change
    add_column :users, :mentorship_role, :integer, default: 0, null: false
    add_column :users, :mentor_capacity, :integer, default: 5, null: false
    add_column :users, :qualification_status, :integer, default: 0, null: false
  end
end

