class AddIconToTurns < ActiveRecord::Migration
    def change
        add_column :turns, :icon, :string
    end
end
