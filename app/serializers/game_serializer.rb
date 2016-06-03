class GameSerializer < ActiveModel::Serializer
    attributes :id, :challenge_id, :white_turn, :offer_draw_by, :game_result
    has_one :user, serializer: UserSerializer
    has_one :opponent, serializer: UserSerializer

    class WithFigures < self
        has_many :figures

        def figures
            object.figures.order(id: :asc)
        end
    end
end
