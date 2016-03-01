class AddProtectedToFigures < ActiveRecord::Migration
    def change
        add_column :figures, :protected_fields, :string, array: true, default: []
    end
end
