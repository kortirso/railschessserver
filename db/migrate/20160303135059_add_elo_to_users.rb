class AddEloToUsers < ActiveRecord::Migration
    def change
        add_column :users, :elo, :integer, default: 1000
    end
end
