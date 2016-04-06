describe 'Turn API' do
    describe 'POST /create' do
        let!(:me) { create :user }
        let!(:game) { create :game, user: me }

        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            context 'with valid attributes' do
                it 'returns 200 status code and correct message' do
                    post "/api/v1/turns", turn: {game: game.id, from: 'e2', to: 'e4'}, format: :json, access_token: access_token.token

                    expect(response).to be_success
                    expect(response.body).to eq 'correct turn'
                end

                it 'saves the new turn in the DB' do
                    expect { post "/api/v1/turns", turn: {game: game.id, from: 'e2', to: 'e4'}, format: :json, access_token: access_token.token }.to change(game.turns, :count).by(1)
                end
            end

            context 'with invalid attributes' do
                it 'return 200 status code and message about error' do
                    post "/api/v1/turns", turn: {game: game.id, from: 'e1', to: 'e3'}, format: :json, access_token: access_token.token

                    expect(response).to be_success
                    expect(response.body).to_not eq 'correct turn'
                end

                it 'does not save the new game in the DB' do
                    expect { post "/api/v1/turns", turn: {game: game.id, from: 'e1', to: 'e3'}, format: :json, access_token: access_token.token }.to_not change(Turn, :count)
                end
            end
        end

        def do_request(options = {})
            post "/api/v1/turns", { turn: {game: game.id, from: 'e2', to: 'e4'}, format: :json }.merge(options)
        end
    end
end