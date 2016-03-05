class ChallengeSerializer < ActiveModel::Serializer
    attributes :id, :color
    has_one :user, serializer: UserSerializer
end
