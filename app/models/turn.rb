class Turn < ApplicationRecord
    belongs_to :game

    validates :game_id, :from, :to, presence: true

    def self.build(game_id, from, to, second_from = '0', second_to = '0')
        game = Game.find(game_id)
        cells_list = game.board.cells
        cell_from, cell_to = cells_list.find_by(name: from), cells_list.find_by(name: to)
        next_turn = game.turns.count % 2 == 1 ? 'white' : 'black'
        Turn.create(game: game, from: from, to: to, second_from: second_from, second_to: second_to, next_turn: next_turn, icon: cell_from.figure.image)
        # удаление чужой фигуры
        enemy = cell_to.figure
        enemy.update(cell: nil) unless enemy.nil?
        # перемещение своей фигуры
        cell_from.figure.update(cell: cell_to)
        if second_from != '0' # взятие на проходе или рокировка
            second_to == '0' ? cells_list.find_by(name: second_from).figure.update(cell: nil) : cells_list.find_by(name: second_from).figure.update(cell: cells_list.find_by(name: second_to))
        elsif second_to != '0' # превращение пешки
            cell_to.figure.update(cell: nil)
            figure = Figure.create board: game.board, type: 'q', color: second_to, image: "figures/#{second_to[0]}q.png", cell: cell_to
        end
        game.finish_turn
    end
end
