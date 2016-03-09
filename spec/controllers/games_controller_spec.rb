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
end
