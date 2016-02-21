class Turn < ActiveRecord::Base
    belongs_to :game

    validates :game_id, :from, :to, presence: true

    def self.build(game_id, from, to)
        game = Game.find(game_id)
        Turn.create(game: game, from: from, to: to)
        game.board.cells.find_by(x_param: from[0], y_param: from[1]).figure.update(cell: game.board.cells.find_by(x_param: to[0], y_param: to[1]))
        turn = game.white_turn ? false : true
        game.update!(white_turn: turn)
    end
end
