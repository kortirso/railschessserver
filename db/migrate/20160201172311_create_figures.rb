class CreateFigures < ActiveRecord::Migration
    def change
        create_table :figures do |t|
            t.string :type
            t.string :color
            t.integer :cell_id
            t.timestamps null: false
        end

        add_index :figures, :cell_id
    end
end
