class Api::V1::DrawsController < Api::V1::BaseController
    before_action :find_game

    def show
        @game.offer_draw(current_resource_owner.id) unless @game.nil?
        render text: 'offer draw'
    end

    def create
        @game.draw_result(current_resource_owner.id, params[:result].to_i) unless @game.nil?
        render text: 'draw result'
    end

    private
    def find_game
        @game = Game.find(params[:id])
    end
end