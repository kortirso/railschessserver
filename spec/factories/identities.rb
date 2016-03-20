FactoryGirl.define do
    factory :identity do
        association :user
        provider nil
        uid nil

        trait :facebook do
            provider :facebook
            uid '123456'
        end

        trait :vk do
            provider :vkontakte
            uid '654321'
        end
    end
end
