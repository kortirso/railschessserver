class Api::V1::GamesController < Api::V1::BaseController
    skip_before_filter :verify_authenticity_token, only: :create

    resource_description do
        short 'Games resources'
        formats ['json']
    end

    api :GET, '/v1/games.json?access_token=TOKEN', 'Returns the information about all games of current user'
    error code: 401, desc: 'Unauthorized'
    example "{'games':[{'id':252,'user':{'id':8,'username':'testing','elo':989},'opponent':{'id':5,'username':'testing1','elo':1000},'challenge_id':null,'white_turn':true,'offer_draw_by':null,'game_result':null}]}"
    def index
        respond_with games: ActiveModel::ArraySerializer.new(current_resource_owner.users_games.current.to_a, each_serializer: GameSerializer)
    end

    api :GET, '/v1/games/:id.json?access_token=TOKEN', 'Returns the information about current game'
    error code: 400, desc: 'Game showing error'
    error code: 401, desc: 'Unauthorized'
    example "{'with_figures':{'id':252,'challenge_id':null,'white_turn':true,'offer_draw_by':null,'game_result':null,'user':{'id':2,'username':'First_user','elo':1118},'opponent':{'id':8,'username':'testing','elo':989},'figures':[{'id':7527,'color':'white','type':'p','cell_name':'a2'}]}}"
    example "error: 'Game is private, you dont have access'"
    example "error: 'Game does not exist'"
    def show
        res = Game.find_accessable(params[:id], current_resource_owner.id)
        if res.kind_of?(String)
            render json: { error: res }, status: 400
        else
            respond_with res, serializer: GameSerializer::WithFigures
        end
    end

    api :POST, '/v1/games.json', 'Creates game from challenge'
    param :access_token, String, desc: 'Token info', required: true
    param :game, Hash, required: true do
        param :challenge, String, desc: 'Challenge ID', required: true
    end
    meta game: { challenge: 1 }
    error code: 400, desc: 'Game creation error'
    error code: 401, desc: 'Unauthorized'
    example "{'game':{'id':272,'user':{'id':8,'username':'testing','elo':989},'opponent':{'id':5,'username':'testing1','elo':1000},'challenge_id':null,'white_turn':true,'offer_draw_by':null,'game_result':null}}"
    example "error: 'Challenge does not exist'"
    example "error: 'You cant create game against you'"
    example "error: 'You cant create game, challenge is not for you'"
    def create
        res = Game.create_from_challenge(params[:game][:challenge].to_i, current_resource_owner.id)
        if res.kind_of?(String)
            render json: { error: res }, status: 400
        else
            respond_with res, serializer: GameSerializer
        end
    end
end