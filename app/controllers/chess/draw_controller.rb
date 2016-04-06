class Chess::DrawController < ApplicationController
    before_action :authenticate_user!
    before_action :find_game
    
    def index
        @game.offer_draw(current_user.id) !@game.nil? && @game.is_player?(current_user.id)
        render nothing: true
    end

    def result
        @game.draw_result(current_user.id, params[:result].to_i) !@game.nil? && @game.is_player?(current_user.id)
        render nothing: true
    end

    private
    def find_game
        @game = Game.find(params[:id])
    end
end