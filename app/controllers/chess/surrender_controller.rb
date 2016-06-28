class Chess::SurrenderController < ApplicationController
    before_action :authenticate_user!
    before_action :find_game
    
    def show
        @game.complete(current_user.id == @game.user_id ? 0 : 1) if @game && @game.is_player?(current_user.id)
        render nothing: true
    end

    private
    def find_game
        @game = Game.find_by(id: params[:id])
    end
end