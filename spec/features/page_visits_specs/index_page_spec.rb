require_relative '../feature_helper'

RSpec.feature 'Visit index page', type: :feature do
    let!(:open_game) { create :game }
    let!(:closed_game) { create :game, :without_access }

    describe 'Unauthenticated user' do
        before { visit games_en_path }

        it 'visit page with game rooms' do
            expect(page).to have_content I18n.t('games.h1')
        end

        it 'doesnt see current_games block' do
            expect(page).to_not have_css('#current_games')
        end

        it 'doesnt see new_game block' do
            expect(page).to_not have_css('#new_game')
        end

        it 'doesnt see challenges block' do
            expect(page).to_not have_css('#challenges')
        end

        context 'last_public_games block' do
            it 'user see it' do
                expect(page).to have_css('#last_public_games')
            end

            it 'there is open game' do
                expect(page).to have_content("#{I18n.t('games.game')} №#{open_game.id}")
            end

            it 'and no closed games' do
                expect(page).to_not have_content("#{I18n.t('games.game')} №#{closed_game.id}")
            end

            it 'can click on View button' do
                within("#game_block_#{open_game.id}") { click_on I18n.t('games.view') }

                expect(page).to have_css('#all_board')
                within('#data p:nth-of-type(2)') { expect(page).to have_content("№#{open_game.id}") }
            end
        end
    end

    describe 'Authenticated user' do
        let!(:user) { create(:user) }
        let!(:user_game) { create :game, user: user }
        let!(:open_game) { create :game }
        let!(:closed_game) { create :game, :without_access }
        before do
            sign_in(user)
            visit games_en_path
        end

        it 'visit page with game rooms' do
            expect(page).to have_content I18n.t('games.h1')
        end

        context 'current_games block' do
            it 'user see it' do
                expect(page).to have_css('#current_games')
            end

            it 'there is user game' do
                within("#current_games") { expect(page).to have_content("#{I18n.t('games.game')} №#{user_game.id}") }
            end

            it 'and no not_users games' do
                within("#current_games") do
                    expect(page).to_not have_content("#{I18n.t('games.game')} №#{open_game.id}")
                    expect(page).to_not have_content("#{I18n.t('games.game')} №#{closed_game.id}")
                end
            end

            it 'can click on View button' do
                within("#game_block_#{user_game.id}") { click_on I18n.t('games.view') }
                
                expect(page).to have_css('#all_board')
                within('#data p:nth-of-type(2)') { expect(page).to have_content("№#{user_game.id}") }
            end
        end

        context 'last_public_games block' do
            it 'user see it' do
                expect(page).to have_css('#last_public_games')
            end

            it 'there is no user game' do
                within("#last_public_games") { expect(page).to_not have_content("#{I18n.t('games.game')} №#{user_game.id}") }
            end

            it 'there is open not_users games' do
                within("#last_public_games") { expect(page).to have_content("#{I18n.t('games.game')} №#{open_game.id}") }
            end

            it 'and no not_users games' do
                within("#last_public_games") { expect(page).to_not have_content("#{I18n.t('games.game')} №#{closed_game.id}") }
            end

            it 'can click on View button' do
                within("#game_block_#{open_game.id}") { click_on I18n.t('games.view') }
                
                expect(page).to have_css('#all_board')
                within('#data p:nth-of-type(2)') { expect(page).to have_content("№#{open_game.id}") }
            end
        end

        context 'new_game block' do
            it 'user see it' do
                expect(page).to have_css('#new_game')
            end
        end

        context 'challenges block' do
            it 'user see it' do
                expect(page).to have_css('#challenges')
            end
        end
    end
end