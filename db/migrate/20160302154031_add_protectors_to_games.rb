class AddProtectorsToGames < ActiveRecord::Migration
    def change
        add_column :games, :w_king_protectors, :string, array: true, default: []
        add_column :games, :b_king_protectors, :string, array: true, default: []
    end
end
