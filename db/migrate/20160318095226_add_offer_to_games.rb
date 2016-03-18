class AddOfferToGames < ActiveRecord::Migration
    def change
        add_column :games, :offer_draw_by, :integer, default: nil
    end
end
