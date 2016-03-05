class ChallengesController < ApplicationController
    before_action :authenticate_user!

    def create
        opponent_id = params[:challenge][:opponent_id]
        if opponent_id.empty?
            challenge = Challenge.create user_id: current_user.id, access: params[:challenge][:access], color: params[:challenge][:color]
            PrivatePub.publish_to "/users/challenges", challenge: ChallengeSerializer.new(challenge).serializable_hash.to_json
        else
            challenge = Challenge.create user_id: current_user.id, access: params[:challenge][:access], color: params[:challenge][:color], opponent_id: opponent_id
            challenge_json = ChallengeSerializer.new(challenge).serializable_hash.to_json
            PrivatePub.publish_to "/users/#{current_user.id}/challenges", challenge: challenge_json
            PrivatePub.publish_to "/users/#{opponent_id}/challenges", challenge: challenge_json
        end
        render nothing: true
    end

    def destroy
        challenge = Challenge.find(params[:id])
        if challenge.user_id == current_user.id || challenge.opponent_id == current_user.id
            PrivatePub.publish_to "/users/games", challenge: ChallengeSerializer.new(challenge).serializable_hash.to_json
            challenge.destroy
        end
        render nothing: true
    end
end
