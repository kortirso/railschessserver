class Api::V1::ProfilesController < Api::V1::BaseController
    def me
        respond_with current_resource_owner
    end

    def all
        respond_with profiles: ActiveModel::ArraySerializer.new(User.where.not(id: current_resource_owner).order(id: :asc).to_a, each_serializer: UserSerializer)
    end
end