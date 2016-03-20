class CreateAis < ActiveRecord::Migration
    def change
        create_table :ais do |t|
            t.integer :elo, default: 1
            t.timestamps null: false
        end

        add_column :games, :ai_id, :integer
        add_index :games, :ai_id
    end
end
