class AddGuestToGames < ActiveRecord::Migration
    def change
        add_column :games, :guest, :string, default: nil
    end
end
