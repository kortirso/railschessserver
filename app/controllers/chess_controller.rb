class ChessController < ApplicationController
    def make_turn
        @from = params[:turn][:from]
        @to = params[:turn][:to]
        @game = Game.find(params[:turn][:game])

        Turn.create(game: @game, from: @from, to: @to)
        @game.board.cells.find_by(x_param: @from[0], y_param: @from[1]).figure.update(cell: @game.board.cells.find_by(x_param: @to[0], y_param: @to[1]))
    end
end
