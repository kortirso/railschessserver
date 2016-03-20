require_relative 'feature_helper'

RSpec.feature "Registration management", type: :feature do
    describe 'Unauthenticated user can' do
        context 'try sign up' do
            before { visit root_path }

            it 'with all information' do
                click_button I18n.t('auth.signup')
                within('#sign_up form#new_user') do
                    fill_in 'user_username', with: 'test'
                    fill_in 'user_email', with: 'test@gmail.com'
                    fill_in 'user_password', with: 'password'
                    fill_in 'user_password_confirmation', with: 'password'

                    click_button I18n.t('auth.signup')
                end

                expect(page).to have_content I18n.t('auth.login_as')
            end

            it 'without all information' do
                click_button I18n.t('auth.signup')
                within('#sign_up form#new_user') do
                    fill_in 'user_username', with: ''
                    fill_in 'user_email', with: ''
                    fill_in 'user_password', with: 'password'
                    fill_in 'user_password_confirmation', with: 'password'

                    click_button I18n.t('auth.signup')
                end

                expect(page).to have_content I18n.t('auth.signup')
            end
        end

        context 'try login' do
            let(:user) { create :user }
            before { visit root_path }

            it 'when he registered' do
                within('#login form#new_user') do
                    fill_in 'user_username', with: user.username
                    fill_in 'user_password', with: user.password

                    click_button I18n.t('auth.login')
                end

                expect(page).to have_content I18n.t('auth.login_as')
            end

            it 'without some information' do
                within('#login form#new_user') do
                    fill_in 'user_username', with: ''
                    fill_in 'user_password', with: user.password

                    click_button I18n.t('auth.login')
                end

                expect(page).to_not have_content I18n.t('auth.login_as')
                expect(page).to have_content I18n.t('auth.signup')
            end

            it 'when he not registered' do
                within('#login form#new_user') do
                    fill_in 'user_username', with: 'random'
                    fill_in 'user_password', with: 'random_pass'

                    click_button I18n.t('auth.login')
                end

                expect(page).to_not have_content I18n.t('auth.login_as')
                expect(page).to have_content I18n.t('auth.signup')
            end
        end
    end

    describe 'Logged user can' do
        let(:user) { create(:user) }

        it 'logoff' do
            login_as(user, scope: :user)
            visit root_path
            click_on 'destroy'

            expect(page).to have_content I18n.t('auth.signup')
        end
    end
end