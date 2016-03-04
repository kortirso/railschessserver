class Chess::SurrenderController < ApplicationController
    before_action :authenticate_user!
    
    def index
        game = Game.find(params[:game])
        game.complete(params[:user].to_i == game.user_id ? 0 : 1)
        PrivatePub.publish_to "/games/#{game.id}", game: game.to_json
        render nothing: true
    end
end