class RemoveGametextFromGames < ActiveRecord::Migration
    def change
        remove_column :games, :game_result_text
    end
end
