class UserSerializer < ActiveModel::Serializer
    attributes :id, :username, :elo
end
