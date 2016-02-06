FactoryGirl.define do
    factory :game do
        access true
        opponent_id 0
        association :user

        trait :invalid do
            access ''
            opponent_id ''
        end
    end
end
