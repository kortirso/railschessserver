RSpec.describe GamesController, type: :controller do
    describe 'GET #index' do
        context 'Logged user' do
            sign_in_user
            let(:games) { create_list(:game, 2, user: @current_user) }

            it 'collect an array of users games' do
                get :index, locale: 'en'

                expect(assigns(:users_games)).to match_array(games)
            end
        end

        it 'renders index view' do
            get :index, locale: 'en'

            expect(response).to render_template :index
        end
    end

    describe 'GET #show' do
        let(:game) { create :game }
        before { get :show, id: game, locale: 'en' }

        it 'assigns the requested game to @game' do
            expect(assigns(:game)).to eq game
        end

        it 'renders show view' do
            expect(response).to render_template :show
        end
    end

    describe 'POST #create' do
        let(:opponent) { create :user }
        let(:opponents_challenge) { create :challenge, opponent: opponent }
        let!(:challenge) { create :challenge }

        context 'Guest user' do
            it 'cant create games' do
                expect { post :create, game: { challenge: challenge.id }, locale: 'en' }.to_not change(Game, :count)
            end
        end

        context 'Logged user' do
            sign_in_user
            let(:users_challenge) { create :challenge, user: @current_user }

            context 'dont create game with invalid data' do
                it 'if challenge doesnt exist' do
                    expect { post :create, game: { challenge: '1000' }, locale: 'en' }.to_not change(Game, :count)
                end

                it 'if user is owner of challenge' do
                    expect { post :create, game: { challenge: users_challenge.id }, locale: 'en' }.to_not change(Game, :count)
                end

                it 'if challenge is not for user' do
                    expect { post :create, game: { challenge: opponents_challenge.id }, locale: 'en' }.to_not change(Game, :count)
                end
            end

            context 'creates game with valid data' do
                let!(:for_user_challenge) { create :challenge, opponent: @current_user }

                it 'if challenge for user' do
                    expect { post :create, game: { challenge: for_user_challenge.id }, locale: 'en' }.to change(Game, :count).by(1)
                end

                it 'if challenge open for all' do
                    expect { post :create, game: { challenge: challenge.id }, locale: 'en' }.to change(Game, :count).by(1)
                end

                it 'and remove challenge from DB' do
                    expect { post :create, game: { challenge: challenge.id }, locale: 'en' }.to change(Challenge, :count).by(-1)
                end
            end
        end
    end
end
