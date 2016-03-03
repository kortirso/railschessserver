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
        figures_list, cells_list = self.figures, self.cells
        f = figures_list.where(type: 'p', color: 'white')
        cells_list.where(y_param: '2').order(id: :asc).each_with_index { |cell, index| f[index].update(cell: cell) }
        f = figures_list.where(type: 'p', color: 'black')
        cells_list.where(y_param: '7').order(id: :asc).each_with_index { |cell, index| f[index].update(cell: cell) }
        %w(white black).each_with_index do |color, index|
            line = "#{index * 7 + 1}"
            figures_list.where(type: 'r', color: color).first.update(cell: cells_list.find_by(name: "a#{line}"))
            figures_list.where(type: 'r', color: color).last.update(cell: cells_list.find_by(name: "h#{line}"))
            figures_list.where(type: 'n', color: color).first.update(cell: cells_list.find_by(name: "b#{line}"))
            figures_list.where(type: 'n', color: color).last.update(cell: cells_list.find_by(name: "g#{line}"))
            figures_list.where(type: 'b', color: color).first.update(cell: cells_list.find_by(name: "c#{line}"))
            figures_list.where(type: 'b', color: color).last.update(cell: cells_list.find_by(name: "f#{line}"))
            figures_list.find_by(type: 'k', color: color).update(cell: cells_list.find_by(name: "e#{line}"))
            figures_list.find_by(type: 'q', color: color).update(cell: cells_list.find_by(name: "d#{line}"))
        end
    end

    def check_beaten_fields
        board_figures, range = [], [[], [], [], []]
        f = self.figures.on_the_board.includes(:cell)
        f.each { |figure| board_figures.push([figure.cell.name, figure.color]) }
        f.each do |figure|
            figure.check_beaten_fields(board_figures)
            if figure.color == 'white'
                range[0] += figure.beaten_fields
                range[1] += figure.protected_fields
            else
                range[2] += figure.beaten_fields
                range[3] += figure.protected_fields
            end
        end
        self.game.update(white_beats: range[0].uniq, white_protectes: range[1].uniq, black_beats: range[2].uniq, black_protectes: range[3].uniq)
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
