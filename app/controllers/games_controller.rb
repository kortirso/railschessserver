class GamesController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :game_find, only: :show
    before_action :get_last_games, only: :index

    def index
        
    end

    def show
        @figures = @game.board.figures.includes(:cell)
    end

    def new
        @game = Game.new
    end

    def create
        params[:game][:opponent_id].empty? ? redirect_to(new_game_url) : redirect_to(@game = Game.build(current_user.id, params[:game][:opponent_id], params[:game][:access]))
    end

    private
    def game_find
        @game = Game.find(params[:id])
    end

    def get_last_games
        @last_games = Game.accessable.order(id: :desc).limit(10)
    end
end
