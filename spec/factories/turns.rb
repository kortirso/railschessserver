FactoryGirl.define do
    factory :turn do
        association :game
        from 'e2'
        to 'e4'
    end
end
