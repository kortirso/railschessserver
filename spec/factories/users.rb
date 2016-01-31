FactoryGirl.define do
    factory :user do
        sequence(:username) { |i| "tester#{i}" }
        sequence(:email) { |i| "tester#{i}@gmail.com" }
        password 'password'
    end
end