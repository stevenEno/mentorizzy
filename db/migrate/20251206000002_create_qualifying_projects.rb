class CreateQualifyingProjects < ActiveRecord::Migration[8.2]
  def change
    create_table :qualifying_projects, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :teen_id, null: false
      t.string :title, null: false
      t.text :description, null: false
      t.string :submission_url
      t.text :feedback
      t.string :status, default: "not_started", null: false
      t.uuid :reviewed_by_id
      t.datetime :reviewed_at
      t.timestamps

      t.index :account_id
      t.index :teen_id
      t.index :reviewed_by_id
      t.index [:teen_id, :status]
    end
  end
end

