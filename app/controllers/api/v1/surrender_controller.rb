class Api::V1::SurrenderController < Api::V1::BaseController
    def show
        game = Game.find(params[:id])
        game.complete(current_resource_owner.id == game.user_id ? 0 : 1) unless game.nil?
        respond_with game: game
    end
end