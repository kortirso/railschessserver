describe 'Draw API' do
    describe 'GET /show' do
        let!(:me) { create :user }
        let!(:game) { create :game, user_id: me.id }

        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }
            
            before { get "/api/v1/draws/#{game.id}", format: :json, access_token: access_token.token }

            it 'returns 200 status' do
                expect(response).to be_success
                expect(response.body).to eq 'offer draw'
            end

            it 'and changes game draw status' do
                game.reload

                expect(game.offer_draw_by).to_not eq nil
            end
        end

        def do_request(options = {})
            get "/api/v1/draws/#{game.id}", { format: :json }.merge(options)
        end
    end

    describe 'POST /create' do
        let!(:me) { create :user }
        let!(:game) { create :game, user_id: me.id }

        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            it 'returns 200 status code and correct message' do
                post "/api/v1/draws", id: game.id, result: '1', format: :json, access_token: access_token.token

                expect(response).to be_success
                expect(response.body).to eq 'draw result'
            end

            it 'and changes game draw status to nil when cancel' do
                post "/api/v1/draws", id: game.id, result: '0', format: :json, access_token: access_token.token
                game.reload

                expect(game.offer_draw_by).to eq nil
            end

            it 'and changes game status when confirm' do
                post "/api/v1/draws", id: game.id, result: '1', format: :json, access_token: access_token.token
                game.reload

                expect(game.game_result).to eq 0.5
            end
        end

        def do_request(options = {})
            post "/api/v1/draws", { id: game.id, result: '1', format: :json }.merge(options)
        end
    end
end