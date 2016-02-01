class CreateCells < ActiveRecord::Migration
    def change
        create_table :cells do |t|
            t.string :x_param
            t.string :y_param
            t.integer :board_id
            t.timestamps null: false
        end

        add_index :cells, :board_id
    end
end
