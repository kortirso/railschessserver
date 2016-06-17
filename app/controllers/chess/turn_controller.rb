class Chess::TurnController < ApplicationController
    before_action :find_game
    before_action :checks_before_turn

    def index
        unless @turn_error.is_a? String
            @turn_error.nil? ? Turn.build(@game.id, @from, @to) : Turn.build(@game.id, @from, @to, @turn_error[0], @turn_error[1])
            render nothing: true
        end
    end

    private
    def find_game
        @game = Game.find_by(id: params[:turn][:game])
        @from = params[:turn][:from]
        @to = params[:turn][:to]
    end

    def checks_before_turn
        @turn_error = current_user.nil? ? 'You dont have access' : nil
        return unless @turn_error.nil?
        @turn_error = @game.nil? ? 'Game doesnt exist' : nil
        return unless @turn_error.nil?
        @turn_error = @game.checks_before_turn(current_user.id, @from, @to)
    end
end
