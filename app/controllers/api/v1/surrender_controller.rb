class Api::V1::SurrenderController < Api::V1::BaseController
    before_action :find_game
    before_action :check_player

    resource_description do
        short 'Surrender resources'
        formats ['json']
    end

    api :GET, '/v1/surrender/:id.json?access_token=TOKEN', 'Set signal from surrender'
    error code: 400, desc: 'Surdending error'
    error code: 401, desc: 'Unauthorized'
    example "{'game':{'id':272,'user':{'id':8,'username':'testing','elo':989},'opponent':{'id':5,'username':'testing1','elo':1000},'challenge_id':null,'white_turn':true,'offer_draw_by':8,'game_result':0}}"
    example "error: 'Game does not exist'"
    example "error: 'You are not game player'"
    def show
        @game.complete(current_resource_owner.id == @game.user_id ? 0 : 1)
        respond_with @game, serializer: GameSerializer
    end

    private
    def find_game
        @game = Game.find_by(id: params[:id])
        render json: { error: 'Game does not exist' }, status: 400 if @game.nil?
    end

    def check_player
        render json: { error: 'You are not game player' }, status: 400 unless @game.is_player?(current_resource_owner.id)
    end
end