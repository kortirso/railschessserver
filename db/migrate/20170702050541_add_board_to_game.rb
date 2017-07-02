class AddBoardToGame < ActiveRecord::Migration[5.1]
    def change
        execute 'create extension hstore'
        add_column :games, :board, :hstore
    end
end
