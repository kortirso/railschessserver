class AddImageToFigure < ActiveRecord::Migration
    def change
        add_column :figures, :image, :string
    end
end
