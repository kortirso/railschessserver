describe 'Draw API' do
    describe 'GET /show' do
        let!(:me) { create :user }
        let!(:game) { create :game, user_id: me.id }

        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }
            
            context 'for game where user is player' do
                before { get "/api/v1/draws/#{game.id}", format: :json, access_token: access_token.token }

                it 'returns 200 status' do
                    expect(response).to be_success
                end

                it 'contains reloaded game object' do
                    game.reload

                    expect(response.body).to be_json_eql(game.to_json).at_path('game')
                end

                it 'and changes game draw status' do
                    game.reload

                    expect(game.offer_draw_by).to_not eq nil
                end
            end

            context 'for game where user is not player' do
                let!(:new_game) { create :game }

                before { get "/api/v1/draws/#{new_game.id}", format: :json, access_token: access_token.token }

                it 'returns 200 status and error message' do
                    expect(response).to be_success
                    expect(response.body).to eq 'error'
                end

                it 'and does not change game draw status' do
                    game.reload

                    expect(game.offer_draw_by).to eq nil
                end
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

            context 'for game where user is player' do
                context 'when result is 1' do
                    before { get "/api/v1/draws/result/#{game.id}/1", format: :json, access_token: access_token.token }

                    it 'returns 200 status code' do
                        expect(response).to be_success
                    end

                    it 'contains reloaded game object' do
                        game.reload

                        expect(response.body).to be_json_eql(game.to_json).at_path('game')
                    end

                    it 'and changes game status when confirm' do
                        game.reload

                        expect(game.game_result).to eq 0.5
                    end
                end

                it 'and changes game draw status to nil when cancel' do
                    get "/api/v1/draws/result/#{game.id}/0", format: :json, access_token: access_token.token
                    game.reload

                    expect(game.offer_draw_by).to eq nil
                end
            end

            context 'for game where user is not player' do
                let!(:new_game) { create :game }

                before { get "/api/v1/draws/result/#{new_game.id}/1", format: :json, access_token: access_token.token }

                 it 'returns 200 status code and error message' do
                    expect(response).to be_success
                    expect(response.body).to eq 'error'
                end

                it 'and does not change game status' do
                    new_game.reload

                    expect(new_game.game_result).to eq nil
                end
            end
        end

        def do_request(options = {})
            get "/api/v1/draws/result/#{game.id}/1", { format: :json }.merge(options)
        end
    end
end