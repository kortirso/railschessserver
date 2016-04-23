class Api::V1::ChallengesController < Api::V1::BaseController
    skip_before_filter :verify_authenticity_token, only: [:create, :destroy]

    resource_description do
        short 'Challenges resources'
        formats ['json']
    end

    api :GET, '/v1/challenges.json&access_token=TOKEN', 'Returns the information about all challenges accessable for current user'
    param :access_token, String, desc: 'Token info', required: true
    error code: 401, desc: 'Unauthorized'
    example "{'challenges':[{'id':163,'user_id':8,'opponent_id':5,'color':'random','access':true,'created_at':'2016-03-24T13:18:58.523Z','updated_at':'2016-03-24T13:18:58.523Z'},{'id':164,'user_id':8,'opponent_id':null,'color':'random','access':true,'created_at':'2016-03-24T13:20:31.119Z','updated_at':'2016-03-24T13:20:31.119Z'}]}"
    
    def index
        respond_with challenges: Challenge.accessable(current_resource_owner.id)
    end

    api :POST, '/v1/challenges.json', 'Returns the information about all challenges accessable for current user'
    param :access_token, String, desc: 'Token info', required: true
    error code: 401, desc: 'Unauthorized'
    example "{'challenge':{'id':163,'user':{'id':8,'username':'testing','elo':1000},'opponent_id':null,'color':'random','access':true}}"
    example 'User does not exist;Error access parameter, must be 1 or 0;Error color parameter, must be white, black or random'

    def create
        @challenge = Challenge.build(current_resource_owner.id, (params[:challenge][:opponent_id].empty? ? nil : params[:challenge][:opponent_id]), params[:challenge][:access], params[:challenge][:color])
        if @challenge.kind_of?(String)
            render text: @challenge
        else
            respond_with @challenge
        end
    end

    api :DELETE, '/v1/challenges/:id', 'Destroy challenge if current user can do this'
    param :access_token, String, desc: 'Token info', required: true
    error code: 401, desc: 'Unauthorized'
    example 'Challenge is deleted'
    example 'Error, you can not destroy challenge'
    example 'Error, challenge does not exist'

    def destroy
        text = 'Challenge is deleted'
        @challenge = Challenge.find_by(id: params[:id])
         if @challenge
            @challenge.is_player?(current_resource_owner.id) ? @challenge.del : text = 'Error, you can not destroy challenge'
        else
            text = 'Error, challenge does not exist'
        end
        render text: text
    end
end