class Api::V1::TurnsController < Api::V1::BaseController
    before_action :find_game
    before_action :checks_before_turn

    api :POST, '/v1/turns.json', 'Creates turn in the game'
    param :access_token, String, desc: 'Token info', required: true
    param :turn, Hash, required: true do
        param :game, String, desc: 'Game ID', required: true
        param :from, String, desc: 'From square', required: true
        param :to, String, desc: 'To square', required: true
    end
    meta turn: { game: 1, from: 'a1', to: 'a2' }
    error code: 400, desc: 'Game creation error'
    error code: 401, desc: 'Unauthorized'
    example "'None, correct turn'"
    example "'Incorrect turn'"
    def create
        if !@turn_error.is_a? String
            @turn_error.nil? ? Turn.build(@game.id, @from, @to) : Turn.build(@game.id, @from, @to, @turn_error[0], @turn_error[1])
            render json: { error: 'None, correct turn' }, status: 200
        else
            render json: { error: @turn_error }, status: 400
        end
    end

    private
    def find_game
        @game = Game.find(params[:turn][:game])
        @from = params[:turn][:from]
        @to = params[:turn][:to]
    end

    def checks_before_turn
        @turn_error = @game.check_users_turn(current_resource_owner.id)
        return unless @turn_error.nil?
        @turn_error = @game.check_cells(@from, @to)
        return unless @turn_error.nil?
        @turn_error = @game.check_right_figure(@from)
        return unless @turn_error.nil?
        @turn_error = @game.check_turn(@from, @to)
    end
end