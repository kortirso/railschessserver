class ChallengesController < ApplicationController
    before_action :authenticate_user!

    def create
        opponent_id = params[:challenge][:opponent_id].empty? ? nil : params[:challenge][:opponent_id]
        Challenge.build(current_user.id, opponent_id, params[:challenge][:access], params[:challenge][:color])
        render nothing: true
    end

    def destroy
        challenge = Challenge.find(params[:id])
        challenge.del(current_user.id) unless challenge.nil?
        render nothing: true
    end
end
