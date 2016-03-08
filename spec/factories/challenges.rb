FactoryGirl.define do
    factory :challenge do
        access true
        association :user
        color 'random'

        trait :with_opponent do
            association :opponent, factory: :user
        end
    end
end
