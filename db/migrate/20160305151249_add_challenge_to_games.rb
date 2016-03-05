class AddChallengeToGames < ActiveRecord::Migration
    def change
        add_column :games, :challenge_id, :integer
        add_index :games, :challenge_id
    end
end
