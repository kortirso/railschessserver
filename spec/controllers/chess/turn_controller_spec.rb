RSpec.describe Chess::TurnController, type: :controller do
    describe 'GET #index' do
        context 'Unauthorized user' do
            let(:game) { create :game }

            it 'cant make turns' do
                expect { xhr :get, :index, locale: 'en', turn: { game: game.id, from: 'e2', to: 'e4' }, format: :js }.to_not change(Turn, :count)
            end
        end

        context 'Authorized user' do
            sign_in_user
            let!(:game) { create :game, user: @current_user }
            let!(:game_with_other_turn) { create :game, :black_turn, user: @current_user }

            context 'cant make turns with invalid data' do
                it 'if game doesnt exist' do
                    expect { xhr :get, :index, locale: 'en', turn: { game: '1000', from: 'e2', to: 'e4' }, format: :js }.to_not change(Turn, :count)
                end

                it 'if it other users turn' do
                    expect { xhr :get, :index, locale: 'en', turn: { game: game_with_other_turn.id, from: 'e2', to: 'e4' }, format: :js }.to_not change(Turn, :count)
                end

                it 'if cells are not different' do
                    expect { xhr :get, :index, locale: 'en', turn: { game: game.id, from: 'e2', to: 'e2' }, format: :js }.to_not change(Turn, :count)
                end

                it 'if figure doesnt belong to user' do
                    expect { xhr :get, :index, locale: 'en', turn: { game: game.id, from: 'e7', to: 'e6' }, format: :js }.to_not change(Turn, :count)
                end

                it 'if there is some mistake in the turn' do
                    expect { xhr :get, :index, locale: 'en', turn: { game: game.id, from: 'e2', to: 'e5' }, format: :js }.to_not change(Turn, :count)
                end
            end

            context 'with valid data' do
                it 'can make turn' do
                    expect { xhr :get, :index, locale: 'en', turn: { game: game.id, from: 'e2', to: 'e4' }, format: :js }.to change(Turn, :count).by(1)
                end

                it 'turn order will be for opponent' do
                    xhr :get, :index, locale: 'en', turn: { game: game.id, from: 'e2', to: 'e4' }, format: :js
                    game.reload

                    expect(game.white_turn).to eq false
                end
            end
        end
    end
end
