class Api::V1::ProfilesController < Api::V1::BaseController
    resource_description do
        short 'Users information resources'
        formats ['json']
    end

    api :GET, '/v1/profiles/me.json?access_token=TOKEN', 'Returns the information about the currently logged user'
    error code: 401, desc: 'Unauthorized'
    example "{'id':8,'username':'testing','elo':989}"
    def me
        respond_with current_resource_owner, serializer: UserSerializer
    end

    api :GET, '/v1/profiles/all.json?access_token=TOKEN', 'Returns the information about all users except currently logged user'
    error code: 401, desc: 'Unauthorized'
    example "{'profiles':[{'id':2,'username':'First_user','elo':1118},{'id':3,'username':'Second_user','elo':1000},{'id':5,'username':'kortirso','elo':1000},{'id':7,'username':'tester','elo':1000}]}"
    def all
        respond_with profiles: ActiveModel::Serializer::CollectionSerializer.new(User.where.not(id: current_resource_owner).order(id: :asc).to_a, each_serializer: UserSerializer)
    end
end