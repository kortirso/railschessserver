class GameSerializer < ActiveModel::Serializer
    attributes :id, :challenge_id
    has_one :user, serializer: UserSerializer
    has_one :opponent, serializer: UserSerializer

    class FullData < self
        attributes :figures, :white_turn, :offer_draw_by, :game_result, :guest, :possibles

        def figures
            eval(object.board['figures'])
        end
    end
end
