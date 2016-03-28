FactoryGirl.define do
    factory :figure do
        association :board
        association :cell
        color 'white'
        type 'p'
        image 'figures/wp.png'
    end
end
