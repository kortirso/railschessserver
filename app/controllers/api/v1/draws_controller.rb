class Api::V1::DrawsController < Api::V1::BaseController
    before_action :find_game

    def show
        if !@game.nil? && @game.is_player?(current_resource_owner.id)
            @game.offer_draw(current_resource_owner.id)
            respond_with game: @game
        else
            render text: 'error'
        end
    end

    def result
        if !@game.nil? && @game.is_player?(current_resource_owner.id)
            @game.draw_result(current_resource_owner.id, params[:result].to_i)
            respond_with game: @game
        else
            render text: 'error'
        end
    end

    private
    def find_game
        @game = Game.find(params[:id])
    end
end