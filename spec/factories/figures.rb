FactoryGirl.define do
    factory :figure do
        association :board
        color 'white'
        type 'p'
    end
end
