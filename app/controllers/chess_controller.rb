class ChessController < ApplicationController
    before_action :authenticate_user!
    before_action :find_game
    before_action :checks_before_turn

    def make_turn
        Turn.build(@game, @from, @to) if @turn_error.nil?
    end

    private
    def find_game
        @game = Game.find(params[:turn][:game])
        @from = params[:turn][:from]
        @to = params[:turn][:to]
    end

    def checks_before_turn
        @turn_error = @game.check_users_turn(params[:turn][:user].to_i)
        return unless @turn_error.nil?
        @turn_error = @game.check_right_figure(@from)
    end
end
