class CreateTurns < ActiveRecord::Migration
    def change
        create_table :turns do |t|
            t.integer :game_id
            t.string :from
            t.string :to
            t.timestamps null: false
        end
        add_index :turns, :game_id
    end
end
