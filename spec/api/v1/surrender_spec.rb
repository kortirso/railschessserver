describe 'Surrender API' do
    describe 'GET /show' do
        let!(:me) { create :user }
        let!(:game) { create :game, user_id: me.id }

        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            context 'for game where user is player' do
                before { get "/api/v1/surrender/#{game.id}", format: :json, access_token: access_token.token }

                it 'returns 200 status' do
                    expect(response).to be_success
                end

                it 'contains reloaded game object' do
                    game.reload

                    expect(response.body).to be_json_eql(GameSerializer.new(game).serializable_hash.to_json).at_path('game')
                end

                it 'and game is over' do
                    game.reload

                    expect(game.game_result).to_not eq nil
                end
            end

            context 'for game where user is not player' do
                let!(:new_game) { create :game }

                before { get "/api/v1/surrender/#{new_game.id}", format: :json, access_token: access_token.token }

                it 'returns 400 status and error message' do
                    expect(response.status).to eq 400
                    expect(response.body).to eq "{\"error\":\"You are not game player\"}"
                end

                it 'and game is not over' do
                    game.reload

                    expect(game.game_result).to eq nil
                end
            end

            context 'for unexist game' do
                before { get "/api/v1/surrender/10000", format: :json, access_token: access_token.token }

                it 'returns 400 status and error message' do
                    expect(response.status).to eq 400
                    expect(response.body).to eq "{\"error\":\"Game does not exist\"}"
                end

                it 'and game is not over' do
                    game.reload

                    expect(game.game_result).to eq nil
                end
            end
        end

        def do_request(options = {})
            get "/api/v1/surrender/#{game.id}", { format: :json }.merge(options)
        end
    end
end