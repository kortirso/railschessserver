class AddUsersturnToGame < ActiveRecord::Migration
    def change
        add_column :games, :white_turn, :boolean, default: true
    end
end
