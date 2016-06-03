describe 'Draws API' do
    describe 'POST /create' do
        let!(:me) { create :user }
        let!(:game) { create :game, user: me }

        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            context 'with valid attributes' do
                before do
                    post "/api/v1/draws", draw: {game: game.id, direction: '0', result: '0'}, format: :json, access_token: access_token.token
                    game.reload
                end

                it 'returns 200 status code and game object' do
                    expect(response).to be_success
                    expect(response.body).to be_json_eql(GameSerializer.new(game).serializable_hash.to_json).at_path('game')
                end

                it 'and changes game attribute offer_draw_by' do
                    expect(game.offer_draw_by).to_not eq nil
                end
            end

            context 'with invalid attributes' do
                let!(:other_game) { create :game }

                it 'return 400 status code and message about error if game does not exist' do
                    post "/api/v1/draws", draw: {game: 10000, direction: '0', result: '0'}, format: :json, access_token: access_token.token

                    expect(response.status).to eq 400
                    expect(response.body).to eq "{\"error\":\"Game does not exist\"}"
                end

                context 'if user is not game player' do
                    before do
                        post "/api/v1/draws", draw: {game: other_game.id, direction: '0', result: '0'}, format: :json, access_token: access_token.token
                        other_game.reload
                    end

                    it 'return 400 status code and message about error' do
                        expect(response.status).to eq 400
                        expect(response.body).to eq "{\"error\":\"You are not game player\"}"
                    end

                    it 'and not changes game attribute offer_draw_by' do
                        expect(other_game.offer_draw_by).to eq nil
                    end
                end
            end
        end

        def do_request(options = {})
            post "/api/v1/draws", { draw: {game: game.id, direction: '0', result: '0'}, format: :json }.merge(options)
        end
    end
end