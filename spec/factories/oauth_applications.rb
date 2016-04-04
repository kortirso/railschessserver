FactoryGirl.define do
    factory :oauth_application, class: Doorkeeper::Application do
        name 'Test'
        redirect_uri 'urn:ietf:wg:oauth:2.0:oob'
        uid '0123456789'
        secret '9876543210'
    end
end 