class DropTables < ActiveRecord::Migration[5.1]
    def change
        drop_table :boards
        drop_table :cells
        drop_table :figures
    end
end
