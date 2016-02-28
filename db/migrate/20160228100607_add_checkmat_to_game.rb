class AddCheckmatToGame < ActiveRecord::Migration
    def change
        add_column :games, :white_checkmat, :string, default: nil
        add_column :games, :black_checkmat, :string, default: nil
        add_column :games, :white_beats, :string, array: true, default: []
        add_column :games, :black_beats, :string, array: true, default: []
    end
end
