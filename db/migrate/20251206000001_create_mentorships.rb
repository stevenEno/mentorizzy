class CreateMentorships < ActiveRecord::Migration[8.2]
  def change
    create_table :mentorships, id: :uuid do |t|
      t.uuid :account_id, null: false
      t.uuid :mentor_id, null: false
      t.uuid :teen_id, null: false
      t.string :status, default: "active", null: false
      t.timestamps

      t.index :account_id
      t.index :mentor_id
      t.index :teen_id
      t.index [:mentor_id, :status]
      t.index [:teen_id, :status]
    end
  end
end

