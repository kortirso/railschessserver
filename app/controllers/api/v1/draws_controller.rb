class Api::V1::DrawsController < Api::V1::BaseController
    skip_before_filter :verify_authenticity_token
    before_action :find_game
    before_action :check_player
    before_action :check_params

    resource_description do
        short 'Draws resources'
        formats ['json']
    end

    api :POST, '/v1/draws.json', 'Offers and answers for draws'
    param :access_token, String, desc: 'Token info', required: true
    param :draw, Hash, required: true do
        param :game, String, desc: 'Game ID', required: true
        param :direction, String, desc: '0 - offer draw, 1 - answer', required: true
        param :result, String, desc: '0 - agree, 1 - refuse', required: true, allow_nil: true
    end
    meta draw: { game: 1, direction: '0', result: '' }
    error code: 400, desc: 'Draw creation error'
    error code: 401, desc: 'Unauthorized'
    example "{'game':{'id':272,'user':{'id':8,'username':'testing','elo':989},'opponent':{'id':5,'username':'testing1','elo':1000},'challenge_id':null,'white_turn':true,'offer_draw_by':8,'game_result':null}}"
    example "error: 'Game does not exist'"
    example "error: 'You are not game player'"
    example "error: 'Wrong direction parameter, must be 0 or 1'"
    example "error: 'Wrong result parameter, must be 0 or 1'"
    def create
        params[:draw][:direction] == '0' ? @game.offer_draw(current_resource_owner.id) : @game.draw_result(current_resource_owner.id, params[:draw][:result].to_i)
        respond_with @game, serializer: GameSerializer
    end

    private
    def find_game
        @game = Game.find_by(id: params[:draw][:game])
        render json: { error: 'Game does not exist' }, status: 400 if @game.nil?
    end

    def check_player
        render json: { error: 'You are not game player' }, status: 400 unless @game.is_player?(current_resource_owner.id)
    end

    def check_params
        render json: { error: 'Wrong direction parameter, must be 0 or 1' }, status: 400 unless %w(0 1).include?(params[:draw][:direction])
        render json: { error: 'Wrong result parameter, must be 0 or 1' }, status: 400 if params[:draw][:direction] == '1' && !%w(0 1).include?(params[:draw][:result])
    end
end