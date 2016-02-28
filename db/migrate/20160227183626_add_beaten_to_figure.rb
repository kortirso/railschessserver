class AddBeatenToFigure < ActiveRecord::Migration
    def change
        add_column :figures, :beaten_fields, :string, array: true, default: []
    end
end
