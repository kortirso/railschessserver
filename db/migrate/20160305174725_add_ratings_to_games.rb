class AddRatingsToGames < ActiveRecord::Migration
    def change
        add_column :games, :user_rating, :integer
        add_column :games, :opponent_rating, :integer
    end
end
