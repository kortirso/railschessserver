class Api::V1::ChallengesController < Api::V1::BaseController
    skip_before_filter :verify_authenticity_token, only: [:create, :destroy]

    resource_description do
        short 'Challenges resources'
        formats ['json']
    end

    api :GET, '/v1/challenges.json?access_token=TOKEN', 'Returns the information about all challenges accessable for current user'
    error code: 401, desc: 'Unauthorized'
    example "{'challenges':[{'id':163,'user_id':8,'opponent_id':5,'color':'random','access':true,'created_at':'2016-03-24T13:18:58.523Z','updated_at':'2016-03-24T13:18:58.523Z'},{'id':164,'user_id':8,'opponent_id':null,'color':'random','access':true,'created_at':'2016-03-24T13:20:31.119Z','updated_at':'2016-03-24T13:20:31.119Z'}]}"
    def index
        respond_with challenges: Challenge.accessable(current_resource_owner.id)
    end

    api :POST, '/v1/challenges.json', 'Creates challenge'
    param :access_token, String, desc: 'Token info', required: true
    param :challenge, Hash, required: true do
        param :opponent_id, String, desc: 'Opponent ID', allow_nil: true, required: true
        param :access, String, desc: 'Access level, 0 - private, 1 - public', required: true
        param :color, String, desc: 'Color of figures for play, random, white or black', required: true
    end
    meta challenge: { opponent_id: 1, access: 1, color: 'random' }
    error code: 400, desc: 'Challenge creation error'
    error code: 401, desc: 'Unauthorized'
    example "{'challenge':{'id':163,'user':{'id':8,'username':'testing','elo':1000},'opponent_id':null,'color':'random','access':true}}"
    example "errors: ['User does not exist','Error access parameter, must be 1 or 0','Error color parameter, must be white, black or random]"
    def create
        challenge = Challenge.build(current_resource_owner.id, (params[:challenge][:opponent_id].empty? ? nil : params[:challenge][:opponent_id]), params[:challenge][:access], params[:challenge][:color])
        if challenge.kind_of?(Array)
            render json: { errors: challenge }, status: 400
        else
            respond_with challenge, status: 201
        end
    end

    api :DELETE, '/v1/challenges/:id.json', 'Destroy challenge if current user can do this'
    param :access_token, String, desc: 'Token info', required: true
    error code: 400, desc: 'Challenge deleting error'
    error code: 401, desc: 'Unauthorized'
    example "error: 'none'"
    example "error: 'Error, you cant destroy challenge'"
    example "error: 'Error, challenge does not exist'"
    def destroy
        res = Challenge.del(params[:id], current_resource_owner.id)
        if res.nil?
            render json: { error: 'none' }, status: 200
        else
            render json: { error: res }, status: 400
        end
    end
end