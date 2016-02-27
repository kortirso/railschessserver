class AddCellsToTurns < ActiveRecord::Migration
    def change
        add_column :turns, :second_from, :string, default: nil
        add_column :turns, :second_to, :string, default: nil
    end
end
