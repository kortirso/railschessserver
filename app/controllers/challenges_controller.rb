class ChallengesController < ApplicationController
    before_action :authenticate_user!

    def create
        opponent_id = params[:challenge][:opponent_id].empty? ? nil : params[:challenge][:opponent_id]
        Challenge.build(current_user.id, opponent_id, params[:challenge][:access], params[:challenge][:color])
        render nothing: true
    end

    def destroy
        Challenge.del(params[:id], current_user.id)
        render nothing: true
    end
end
