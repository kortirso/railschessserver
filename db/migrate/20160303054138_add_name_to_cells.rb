class AddNameToCells < ActiveRecord::Migration
    def change
        add_column :cells, :name, :string
    end
end
