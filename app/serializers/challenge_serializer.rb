class ChallengeSerializer < ActiveModel::Serializer
    attributes :id, :color, :access
    has_one :user, serializer: UserSerializer
    has_one :opponent, serializer: UserSerializer
end
