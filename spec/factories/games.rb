FactoryGirl.define do
    factory :game do
        access true
        association :user
        association :opponent, factory: :user
        association :challenge
        white_turn true
        game_result nil

        trait :invalid do
            access ''
            opponent_id ''
        end

        trait :black_turn do
            white_turn false
        end
    end
end
