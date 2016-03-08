FactoryGirl.define do
    factory :user do
        sequence(:username) { |i| "tester#{i}" }
        sequence(:email) { |i| "tester#{i}@gmail.com" }
        password 'password'
        elo 1000
    end
end