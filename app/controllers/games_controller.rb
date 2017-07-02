class GamesController < ApplicationController
    before_action :authenticate_user!, only: :create
    before_action :game_find, only: :show
    before_action :get_last_games, only: :index

    def index
        @challenges = Challenge.accessable(current_user.id).includes(:user) if current_user
    end

    def show; end

    def create
        Game.create_from_challenge(params[:game][:challenge].to_i, current_user.id)
        render nothing: true
    end

    private
    def game_find
        @game = Game.find_by(id: params[:id])
        #render template: 'shared/404', status: 404 if @game.nil? || @game.access == false && (current_user && @game.user_id != current_user.id && @game.opponent_id != current_user.id || !@game.guest.nil? && @game.guest != session[:guest])
    end

    def get_last_games
        @last_games = Game.accessable.current.order(id: :desc).includes(:user, :opponent).limit(16)
        @last_games = @last_games.where('user_id is NULL OR user_id != ? AND opponent_id != ?', current_user.id, current_user.id).limit(6) if current_user
    end
end
