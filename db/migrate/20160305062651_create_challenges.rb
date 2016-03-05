class CreateChallenges < ActiveRecord::Migration
    def change
        create_table :challenges do |t|
            t.integer :user_id
            t.integer :opponent_id, default: nil
            t.string :color
            t.boolean :access, default: true
            t.timestamps null: false
        end

        add_index :challenges, :user_id
        add_index :challenges, :opponent_id
    end
end
