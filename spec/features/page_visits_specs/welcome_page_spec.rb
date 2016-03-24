require_relative '../feature_helper'

RSpec.feature 'Visit welcome page', type: :feature do
    describe 'Unauthenticated user' do
        before { visit root_path }

        it 'see training button' do
            expect(page).to have_content I18n.t('index.training')
        end

        it 'and can start training game' do
            click_on I18n.t('index.training')

            expect(page).to have_css('#all_board')
        end
    end

    describe 'Authenticated user' do
        let(:user) { create(:user) }
        before { sign_in(user) }

        it 'dont see training button' do
            expect(page).to_not have_content I18n.t('index.training')
        end
    end
end