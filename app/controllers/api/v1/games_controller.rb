class Api::V1::GamesController < Api::V1::BaseController
    skip_before_action :verify_authenticity_token, only: :create
    skip_before_action :doorkeeper_authorize!, only: :show

    resource_description do
        short 'Games resources'
        formats ['json']
    end

    api :GET, '/v1/games.json?access_token=TOKEN', 'Returns the information about all games of current user'
    def index
        render json: { games: ActiveModel::Serializer::CollectionSerializer.new(current_resource_owner.users_games.current.to_a, each_serializer: GameSerializer) }
    end

    api :GET, '/v1/games/:id.json', 'Returns the information about current game'
    def show
        game = Game.find(params[:id])
        render json: game, serializer: GameSerializer::FullData
    end

    api :POST, '/v1/games.json', 'Creates game from challenge'
    def create
        res = Game.create_from_challenge(params[:game][:challenge].to_i, current_resource_owner.id)
        if res.kind_of?(String)
            render json: { error: res }, status: 400
        else
            respond_with res, serializer: GameSerializer
        end
    end
end