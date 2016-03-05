class GameSerializer < ActiveModel::Serializer
    attributes :id, :challenge_id
    has_one :user, serializer: UserSerializer
    has_one :opponent, serializer: UserSerializer
end
