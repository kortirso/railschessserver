class AddAttackToFigures < ActiveRecord::Migration
    def change
        add_column :figures, :attack, :boolean, default: false
    end
end
