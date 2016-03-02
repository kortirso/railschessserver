class Board < ActiveRecord::Base
    belongs_to :game
    has_many :cells
    has_many :figures

    validates :game_id, presence: true

    after_create :board_sets

    def self.build(game)
        board = create game: game
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

    def check_beaten_fields
        board_figures = []
        f = self.figures.on_the_board
        f.each { |figure| board_figures.push([figure.cell.cell_name, figure.color]) }
        f.each { |figure| figure.check_beaten_fields(board_figures) }
    end

    def kings_check
        board_figures = []
        f = self.figures.on_the_board
        f.each { |figure| board_figures.push([figure.cell.cell_name, figure.color]) }
        f.where(type: 'k').each { |figure| figure.check_king_cells(board_figures) }
    end

    private
    def board_sets
        Cell.build(self)
        Figure.build(self)
        self.set_figures
        self.check_beaten_fields
    end
end
