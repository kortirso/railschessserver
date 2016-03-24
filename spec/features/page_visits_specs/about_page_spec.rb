require_relative '../feature_helper'

RSpec.feature 'Visit about page', type: :feature do
    describe 'User' do
        before { visit about_index_path }

        it 'can see information about server' do
            expect(page).to have_content I18n.t('about.h1')
        end
    end
end