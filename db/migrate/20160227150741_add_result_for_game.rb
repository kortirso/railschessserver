class AddResultForGame < ActiveRecord::Migration
    def change
        add_column :games, :game_result, :float, default: nil
    end
end
