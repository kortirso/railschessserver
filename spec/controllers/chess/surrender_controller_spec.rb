RSpec.describe Chess::SurrenderController, type: :controller do
    describe 'GET #show' do
        let(:game) { create :game }

        it 'Unauthorized user cant surrender in game' do
            expect { get :show, locale: 'en', id: game.id, format: :js }.to_not change(game, :game_result)
        end

        context 'Authorized user' do
            sign_in_user
            let(:game_with_user) { create :game, user: @current_user }

            it 'if user is not player he cant surrender' do
                expect { get :show, locale: 'en', id: game.id, format: :js }.to_not change(game, :game_result)
            end

            it 'if user is player he can surrender' do
                get :show, locale: 'en', id: game_with_user.id, format: :js
                game_with_user.reload

                expect(game_with_user.game_result).to_not eq nil
            end
        end
    end
end
