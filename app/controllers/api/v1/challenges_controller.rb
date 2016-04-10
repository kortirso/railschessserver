class Api::V1::ChallengesController < Api::V1::BaseController
    def index
        respond_with challenges: Challenge.accessable(current_resource_owner.id)
    end

    def create
        @challenge = Challenge.build(current_resource_owner.id, (params[:challenge][:opponent_id].empty? ? nil : params[:challenge][:opponent_id]), params[:challenge][:access], params[:challenge][:color])
        if @challenge.kind_of?(String)
            render text: @challenge
        else
            respond_with @challenge
        end
    end

    def destroy
        @challenge = Challenge.find_by(id: params[:id])
         if @challenge
            if @challenge.is_player?(current_resource_owner.id)
                @challenge.del(current_resource_owner.id)
                respond_with @challenge
            else
                render text: 'Error, you can not destroy challenge'
            end
        else
            render text: 'Error, challenge does not exist'
        end
    end
end