class CreateBoards < ActiveRecord::Migration
    def change
        create_table :boards do |t|
            t.integer :game_id
            t.timestamps null: false
        end

        add_index :boards, :game_id
    end
end
