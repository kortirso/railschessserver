class AddWhoisturnToTurns < ActiveRecord::Migration
    def change
        add_column :turns, :next_turn, :string
    end
end
