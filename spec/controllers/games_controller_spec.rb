RSpec.describe GamesController, type: :controller do
    describe 'GET #index' do
        context 'Logged user' do
            sign_in_user
            let(:games) { create_list(:game, 2, user: @current_user) }
            before { get :index }

            it 'collect an array of users games' do
                expect(assigns(:users_games)).to match_array(games)
            end
        end

        it 'renders index view' do
            get :index

            expect(response).to render_template :index
        end
    end

    describe 'GET #show' do
        let(:game) { create :game }
        before { get :show, id: game }

        it 'assigns the requested question to @question' do
            expect(assigns(:game)).to eq game
        end

        it 'renders show view' do
            expect(response).to render_template :show
        end
    end

    describe 'GET #new' do
        sign_in_user
        before { get :new }

        it 'assigns a new game to @game' do
            expect(assigns(:game)).to be_a_new(Game)
        end

        it 'renders new view' do
            expect(response).to render_template :new
        end
    end

    describe 'POST #create' do
        sign_in_user

        context 'with valid attributes' do
            it 'saves the new game in the DB and it belongs to current user' do
                expect { post :create, game: attributes_for(:game) }.to change(@current_user.games, :count).by(1)
            end

            it 'redirects to show view' do
                post :create, game: attributes_for(:game)

                expect(response).to redirect_to game_path(assigns(:game))
            end
        end

        context 'with invalid attributes' do
            it 'does not save the new game in the DB' do
                expect { post :create, game: attributes_for(:game, :invalid) }.to_not change(Game, :count)
            end

            it 're-render new view' do
                post :create, game: attributes_for(:game, :invalid)

                expect(response).to redirect_to new_game_path
            end
        end
    end
end
