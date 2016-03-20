FactoryGirl.define do
    factory :figure do
        association :board
        color 'white'
        type 'p'
        image 'figures/wp.png'
    end
end
