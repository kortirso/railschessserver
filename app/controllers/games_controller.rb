class GamesController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :game_find, only: :show
    before_action :get_last_games, only: :index

    def index
        @challenges = Challenge.accessable(current_user.id).order(id: :desc).includes(:user) if current_user
    end

    def show
        @figures = @game.board.figures.includes(:cell)
    end

    def create
        challenge = Challenge.find(params[:game][:challenge].to_i)
        color = case challenge.color
            when 'random' then rand(1)
            when 'white' then 1
            else 0
        end
        game = color == 1 ? Game.build(challenge.user_id, current_user.id, challenge.access, challenge.id) : Game.build(current_user.id, challenge.user_id, challenge.access, challenge.id)
        game_json = GameSerializer.new(game).serializable_hash.to_json
        PrivatePub.publish_to "/users/#{game.user_id}/games", game: game_json
        PrivatePub.publish_to "/users/#{game.opponent_id}/games", game: game_json
        PrivatePub.publish_to "/users/games", challenge: ChallengeSerializer.new(challenge).serializable_hash.to_json
        challenge.destroy
        render nothing: true
    end

    private
    def game_find
        @game = Game.find_by(id: params[:id])
        render template: 'shared/404', status: 404 unless @game
    end

    def get_last_games
        @last_games = Game.accessable.current.order(id: :desc).includes(:user, :opponent).limit(16)
        @last_games = @last_games.where('user_id != ? AND opponent_id != ?', current_user.id, current_user.id).limit(6) if current_user
    end
end
