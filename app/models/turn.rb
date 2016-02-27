class Turn < ActiveRecord::Base
    belongs_to :game

    validates :game_id, :from, :to, presence: true

    def self.build(game_id, from, to, second_from = '0', second_to = '0')
        game = Game.find(game_id)
        new_turn = Turn.create(game: game, from: from, to: to, second_from: second_from, second_to: second_to)
        # удаление чужой фигуры
        enemy = game.board.cells.find_by(x_param: to[0], y_param: to[1]).figure
        enemy.update(cell: nil) unless enemy.nil?
        # перемещение своей фигуры
        game.board.cells.find_by(x_param: from[0], y_param: from[1]).figure.update(cell: game.board.cells.find_by(x_param: to[0], y_param: to[1]))
        if second_from != '0'
            # взятие на проходе или рокировка
            second_to == '0' ? game.board.cells.find_by(x_param: second_from[0], y_param: second_from[1]).figure.update(cell: nil) : game.board.cells.find_by(x_param: second_from[0], y_param: second_from[1]).figure.update(cell: game.board.cells.find_by(x_param: second_to[0], y_param: second_to[1]))
        end
        turn = game.white_turn ? false : true
        game.update(white_turn: turn)
        new_turn
    end
end
