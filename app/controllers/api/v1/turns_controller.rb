class Api::V1::TurnsController < Api::V1::BaseController
    before_action :find_game
    before_action :checks_before_turn

    def create
        if !@turn_error.is_a? String
            @turn_error.nil? ? Turn.build(@game.id, @from, @to) : Turn.build(@game.id, @from, @to, @turn_error[0], @turn_error[1])
            render text: 'correct turn'
        else
            render text: @turn_error
        end
    end

    private
    def find_game
        @game = Game.find(params[:turn][:game])
        @from = params[:turn][:from]
        @to = params[:turn][:to]
    end

    def checks_before_turn
        @turn_error = @game.check_users_turn(current_resource_owner.nil? ? nil : current_resource_owner.id)
        return unless @turn_error.nil?
        @turn_error = @game.check_cells(@from, @to)
        return unless @turn_error.nil?
        @turn_error = @game.check_right_figure(@from)
        return unless @turn_error.nil?
        @turn_error = @game.check_turn(@from, @to)
    end
end