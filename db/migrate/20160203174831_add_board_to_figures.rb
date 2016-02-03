class AddBoardToFigures < ActiveRecord::Migration
    def change
        add_column :figures, :board_id, :integer
        add_index :figures, :board_id
    end
end
