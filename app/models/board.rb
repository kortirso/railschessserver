class Board < ActiveRecord::Base
    belongs_to :game
    has_many :cells
    has_many :figures

    validates :game_id, presence: true

    def self.build(game)
        board = create game: game
        Cell.build(board)
        Figure.build(board)
        board.set_figures
        board
    end

    def set_figures
        f = self.figures.where(type: 'p', color: 'white')
        self.cells.where(y_param: '2').order(id: :asc).each_with_index { |cell, index| f[index].update(cell: cell) }
        f = self.figures.where(type: 'p', color: 'black')
        self.cells.where(y_param: '7').order(id: :asc).each_with_index { |cell, index| f[index].update(cell: cell) }
        %w(white black).each_with_index do |color, index|
            line = "#{index * 7 + 1}"
            self.figures.where(type: 'r', color: color).first.update(cell: self.cells.find_by(x_param: 'a', y_param: line))
            self.figures.where(type: 'r', color: color).last.update(cell: self.cells.find_by(x_param: 'h', y_param: line))
            self.figures.where(type: 'n', color: color).first.update(cell: self.cells.find_by(x_param: 'b', y_param: line))
            self.figures.where(type: 'n', color: color).last.update(cell: self.cells.find_by(x_param: 'g', y_param: line))
            self.figures.where(type: 'b', color: color).first.update(cell: self.cells.find_by(x_param: 'c', y_param: line))
            self.figures.where(type: 'b', color: color).last.update(cell: self.cells.find_by(x_param: 'f', y_param: line))
            self.figures.find_by(type: 'k', color: color).update(cell: self.cells.find_by(x_param: 'e', y_param: line))
            self.figures.find_by(type: 'q', color: color).update(cell: self.cells.find_by(x_param: 'd', y_param: line))
        end
    end
end
