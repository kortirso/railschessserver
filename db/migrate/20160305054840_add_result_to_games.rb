class AddResultToGames < ActiveRecord::Migration
    def change
        add_column :games, :game_result_text, :string, default: nil
    end
end
