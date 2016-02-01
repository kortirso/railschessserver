FactoryGirl.define do
    factory :game do
        access true
        association :user
        association :opponent, factory: :user
    end
end
