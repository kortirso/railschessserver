class Api::V1::ChallengesController < Api::V1::BaseController
    def index
        respond_with challenges: Challenge.accessable(current_resource_owner.id)
    end

    def create
        @challenge = Challenge.build(current_resource_owner.id, (params[:challenge][:opponent_id].empty? ? nil : params[:challenge][:opponent_id]), params[:challenge][:access], params[:challenge][:color])
        respond_with @challenge
    end

    def destroy
        @challenge = Challenge.find(params[:id])
        @challenge.del(current_resource_owner.id) unless @challenge.nil?
        respond_with @challenge
    end
end