class GamesController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :game_find, only: :show
    before_action :get_last_games, only: :index

    def index
        @challenges = Challenge.accessable(current_user.id).order(id: :desc).includes(:user) if current_user
    end

    def show
        @figures = @game.figures.includes(:cell)
    end

    def create
        challenge_id = params[:game][:challenge].to_i
        Game.build(challenge_id, current_user.id) unless Challenge.find(challenge_id).nil?
        render nothing: true
    end

    private
    def game_find
        @game = Game.find_by(id: params[:id])
        render template: 'shared/404', status: 404 if @game.nil? || @game.access == false && (current_user && @game.user_id != current_user.id && @game.opponent_id != current_user.id || !@game.guest.nil? && @game.guest != session[:guest])
    end

    def get_last_games
        @last_games = Game.accessable.current.order(id: :desc).includes(:user, :opponent).limit(16)
        @last_games = @last_games.where('user_id is NULL OR user_id != ? AND opponent_id != ?', current_user.id, current_user.id).limit(6) if current_user
    end
end
