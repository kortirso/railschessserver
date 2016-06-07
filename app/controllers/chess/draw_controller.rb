class Chess::DrawController < ApplicationController
    before_action :authenticate_user!
    before_action :find_game

    def create
        if @game&.is_player?(current_user.id)
            params[:direction] == '0' ? @game.offer_draw(current_user.id) : @game.draw_result(current_user.id, params[:result].to_i)
        end
        render nothing: true
    end

    private
    def find_game
        @game = Game.find_by(id: params[:game])
    end
end