FactoryGirl.define do
    factory :game do
        access true

        association :user
    end
end
