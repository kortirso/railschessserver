class Turn < ActiveRecord::Base
    belongs_to :game

    validates :game_id, :from, :to, presence: true

    def self.build(game_id, from, to, second_from = '0', second_to = '0')
        game = Game.find(game_id)
        board = game.board
        cell_from = board.cells.find_by(x_param: from[0], y_param: from[1])
        cell_to = board.cells.find_by(x_param: to[0], y_param: to[1])
        next_turn = game.turns.count % 2 == 1 ? 'Ход белых' : 'Ход черных'
        new_turn = Turn.create(game: game, from: from, to: to, second_from: second_from, second_to: second_to, next_turn: next_turn)
        # удаление чужой фигуры
        enemy = cell_to.figure
        enemy.update(cell: nil) unless enemy.nil?
        # перемещение своей фигуры
        cell_from.figure.update(cell: cell_to)
        if second_from != '0'
            # взятие на проходе или рокировка
            second_to == '0' ? board.cells.find_by(x_param: second_from[0], y_param: second_from[1]).figure.update(cell: nil) : board.cells.find_by(x_param: second_from[0], y_param: second_from[1]).figure.update(cell: board.cells.find_by(x_param: second_to[0], y_param: second_to[1]))
        elsif second_to != '0'
            cell_to.figure.update(cell: nil)
            figure = Figure.create board: board, type: 'q', color: second_to, image: "figures/#{second_to[0]}q.png"
            figure.update(cell: cell_to)
        end
        turn = game.white_turn ? false : true
        game.update(white_turn: turn)
        board.check_beaten_fields
        game.beat_fields
        board.kings_check
        game.checkmat_check
        new_turn
    end
end
