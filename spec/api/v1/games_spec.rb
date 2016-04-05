describe 'Game API' do
    describe 'GET /index' do
        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:me) { create :user }
            let!(:game) { create :game, user_id: me.id }
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            before { get '/api/v1/games', format: :json, access_token: access_token.token }

            it 'returns 200 status' do
                expect(response).to be_success
            end

            it 'contains list of user games' do
                expect(response.body).to be_json_eql(game.to_json).at_path('games/0')
            end
        end

        def do_request(options = {})
            get "/api/v1/games", { format: :json }.merge(options)
        end
    end

    describe 'GET /show' do
        let!(:me) { create :user }
        let!(:game) { create :game, user_id: me.id }
        let!(:closed_game) { create :game, access: false }

        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            before { get "/api/v1/games/#{game.id}", format: :json, access_token: access_token.token }

            it 'returns 200 status' do
                expect(response).to be_success
            end

            it 'returns 200 status with nul if try access to closed_game' do
                get "/api/v1/games/#{closed_game.id}", format: :json, access_token: access_token.token

                expect(response).to be_success
                expect(response.body).to eq 'no access'
            end

            %w(id challenge_id white_turn).each do |attr|
                it "contains #{attr}" do
                    expect(response.body).to be_json_eql(game.send(attr.to_sym).to_json).at_path("with_figures/#{attr}")
                end
            end

            %w(id username elo).each do |attr|
                it "contains #{attr} for user" do
                    expect(response.body).to be_json_eql(game.user.send(attr.to_sym).to_json).at_path("with_figures/user/#{attr}")
                end

                it "contains #{attr} for opponent" do
                    expect(response.body).to be_json_eql(game.opponent.send(attr.to_sym).to_json).at_path("with_figures/opponent/#{attr}")
                end
            end

            context 'figures' do
                it 'included in question object' do
                    expect(response.body).to have_json_size(32).at_path("with_figures/figures")
                end

                %w(id type color cell_name).each do |attr|
                    it "contains #{attr}" do
                        expect(response.body).to be_json_eql(game.figures.order(id: :asc).first.send(attr.to_sym).to_json).at_path("with_figures/figures/0/#{attr}")
                    end
                end
            end
        end

        def do_request(options = {})
            get "/api/v1/games/#{game.id}", { format: :json }.merge(options)
        end
    end

    describe 'POST /create' do
        let!(:me) { create :user }
        let!(:challenge) { create :challenge, user: me }

        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }
            let!(:battle) { create :challenge, opponent: me }

            context 'with valid attributes' do
                it 'returns 200 status code' do
                    post "/api/v1/games", game: {challenge: battle.id.to_s}, format: :json, access_token: access_token.token

                    expect(response).to be_success
                end

                it 'saves the new game in the DB' do
                    expect { post "/api/v1/games", game: {challenge: battle.id.to_s}, format: :json, access_token: access_token.token }.to change(Game, :count).by(1)
                end

                it 'removes challenge from the DB' do
                    expect { post "/api/v1/games", game: {challenge: battle.id.to_s}, format: :json, access_token: access_token.token }.to change(Challenge, :count).by(-1)
                end
            end

            context 'with invalid attributes' do
                it 'return 200 status code' do
                    post "/api/v1/games", game: {challenge: challenge.id.to_s}, format: :json, access_token: access_token.token

                    expect(response).to be_success
                    expect(response.body).to eq 'error'
                end

                it 'does not save the new game in the DB' do
                    expect { post "/api/v1/games", game: {challenge: challenge.id.to_s}, format: :json, access_token: access_token.token }.to_not change(Game, :count)
                end

                it 'does not remove challenge from the DB' do
                    expect { post "/api/v1/games", game: {challenge: challenge.id.to_s}, format: :json, access_token: access_token.token }.to_not change(Challenge, :count)
                end
            end
        end

        def do_request(options = {})
            post "/api/v1/games", { game: {challenge: challenge.id.to_s}, format: :json }.merge(options)
        end
    end
end