class Chess::TurnController < ApplicationController
    before_action :find_game
    before_action :checks_before_turn

    def index
        unless @turn_error.is_a? String
            @turn_error.nil? ? Turn.build(@game.id, @from, @to) : Turn.build(@game.id, @from, @to, @turn_error[0], @turn_error[1])
            @game.reload
            @game.ai_turn if @game.opponent == User.find_by(username: 'Коала Майк') && @game.game_result.nil?
        end
    end

    private
    def find_game
        @game = Game.find(params[:turn][:game])
        @from = params[:turn][:from]
        @to = params[:turn][:to]
    end

    def checks_before_turn
        @turn_error = @game.check_users_turn(current_user.nil? ? nil : current_user.id) # Чья очередь ходить
        return unless @turn_error.nil?
        @turn_error = @game.check_cells(@from, @to) # Должны быть разные исходная и конечная точки
        return unless @turn_error.nil?
        @turn_error = @game.check_right_figure(@from) # Своей ли фигурой ходит игрок
        return unless @turn_error.nil?
        @turn_error = @game.check_turn(@from, @to) # Проверка правильности хода, проверка на препятствия, проверка, есть ли фигуры в конечной точке
    end
end
