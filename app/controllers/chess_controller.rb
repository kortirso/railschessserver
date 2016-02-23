class ChessController < ApplicationController
    before_action :authenticate_user!
    before_action :find_game
    before_action :checks_before_turn

    def make_turn
        Turn.build(@game.id, @from, @to) if @turn_error.nil?
    end

    private
    def find_game
        @game = Game.find(params[:turn][:game])
        @from = params[:turn][:from]
        @to = params[:turn][:to]
    end

    def checks_before_turn
        @turn_error = @game.check_users_turn(params[:turn][:user].to_i) # Чья очередь ходить
        return unless @turn_error.nil?
        @turn_error = @game.check_cells(@from, @to) # Должны быть разные исходная и конечная точки
        return unless @turn_error.nil?
        @turn_error = @game.check_right_figure(@from) # Своей ли фигурой ходит игрок
        return unless @turn_error.nil?
        @turn_error = @game.check_turn(@from, @to) # Проверка правильности хода, проверка на препятствия
        return unless @turn_error.nil?
        @turn_error = @game.check_finish_cell(@from, @to) # Проверка, есть ли фигуры в конечной точке
    end
end
