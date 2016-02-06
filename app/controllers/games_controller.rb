class GamesController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]

    def index
        @users_games = current_user.users_games if current_user
    end

    def show
        @game = Game.find(params[:id])
        @figures = @game.board.figures
    end

    def new
        @game = Game.new
    end

    def create
        params[:game][:opponent_id].empty? ? redirect_to(new_game_url) : redirect_to(@game = Game.build(current_user.id, params[:game][:opponent_id], params[:game][:access]))
    end
end
