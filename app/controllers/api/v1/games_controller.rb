class Api::V1::GamesController < Api::V1::BaseController
    def index
        respond_with games: current_resource_owner.users_games.current
    end

    def show
        @game = Game.find_by(id: params[:id])
        if @game.access == false && @game.user_id != current_resource_owner.id && @game.opponent_id != current_resource_owner.id
            render text: 'no access'
        else
            respond_with @game, serializer: GameSerializer::WithFigures
        end
    end

    def create
        challenge = Challenge.find(params[:game][:challenge].to_i)
        if !challenge.nil? && challenge.user_id != current_resource_owner.id && challenge.opponent_id.nil? || challenge.opponent_id == current_resource_owner.id
            @game = Game.build(params[:game][:challenge].to_i, current_resource_owner.id)
            respond_with @game, serializer: GameSerializer::WithFigures
        else
            render text: 'error'
        end
    end
end