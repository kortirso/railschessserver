class AddPossiblesToGames < ActiveRecord::Migration
    def change
        add_column :games, :possibles, :string, array: true, default: []
    end
end
