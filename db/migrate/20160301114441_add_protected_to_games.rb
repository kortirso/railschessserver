class AddProtectedToGames < ActiveRecord::Migration
    def change
        add_column :games, :white_protectes, :string, array: true, default: []
        add_column :games, :black_protectes, :string, array: true, default: []
    end
end
