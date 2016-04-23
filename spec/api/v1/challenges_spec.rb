describe 'Challenge API' do
    describe 'GET /index' do
        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:me) { create :user }
            let!(:enemy) { create :user }
            let!(:challenges) { create_list(:challenge, 2, user_id: enemy.id, opponent: nil) }
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            before { get '/api/v1/challenges', format: :json, access_token: access_token.token }

            it 'returns 200 status' do
                expect(response).to be_success
            end

            it 'contains list challenges for user' do
                expect(response.body).to be_json_eql(challenges.to_json).at_path('challenges')
            end
        end

        def do_request(options = {})
            get "/api/v1/challenges", { format: :json }.merge(options)
        end
    end

    describe 'POST /create' do
        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:me) { create :user }
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            context 'with valid attributes' do
                it 'returns 200 status code' do
                    post "/api/v1/challenges", challenge: {opponent_id: '', access: '1', color: 'random'}, format: :json, access_token: access_token.token

                    expect(response).to be_success
                end

                it 'saves the new challenge in the DB' do
                    expect { post "/api/v1/challenges", challenge: {opponent_id: '', access: '1', color: 'random'}, format: :json, access_token: access_token.token }.to change(Challenge, :count).by(1)
                end

                it 'belongs to current user' do
                    expect { post "/api/v1/challenges", challenge: {opponent_id: '', access: '1', color: 'random'}, format: :json, access_token: access_token.token }.to change(me.challenges, :count).by(1)
                end
            end

            context 'with invalid attributes' do
                it 'returns 200 status code and error message' do
                    post "/api/v1/challenges", challenge: {opponent_id: '', access: '1', color: 'error'}, format: :json, access_token: access_token.token

                    expect(response).to be_success
                    expect(response.body).to eq 'Error color parameter, must be white, black or random'
                end

                it 'does not save the new answer in the DB' do
                    expect { post "/api/v1/challenges", challenge: {opponent_id: '', access: '1', color: 'error'}, format: :json, access_token: access_token.token }.to_not change(Challenge, :count)
                end
            end
        end

        def do_request(options = {})
            post "/api/v1/challenges", { format: :json }.merge(options)
        end
    end

    describe 'DELETE /destroy' do
        let!(:me) { create :user }
        let!(:challenge) { create :challenge, user: me }
        
        it_behaves_like 'API Authenticable'

        context 'authorized' do
            let!(:access_token) { create :access_token, resource_owner_id: me.id }

            it 'returns 200 status code and success message' do
                delete "/api/v1/challenges/#{challenge.id}", format: :json, access_token: access_token.token

                expect(response).to be_success
                expect(response.body).to eq 'Challenge is deleted'
            end

            it 'remove challenge from the DB' do
                expect { delete "/api/v1/challenges/#{challenge.id}", format: :json, access_token: access_token.token }.to change(Challenge, :count).by(-1)
            end

            context 'when challenge not for user' do
                let!(:other_challenge) { create :challenge }

                it 'returns 200 status code and error message' do
                    delete "/api/v1/challenges/#{other_challenge.id}", format: :json, access_token: access_token.token

                    expect(response).to be_success
                    expect(response.body).to eq 'Error, you can not destroy challenge'
                end

                it 'and does not remove other challenge from the DB' do
                    expect { delete "/api/v1/challenges/#{other_challenge.id}", format: :json, access_token: access_token.token }.to_not change(Challenge, :count)
                end
            end

            context 'when challenge does not exist' do
                it 'returns 200 status code and error message' do
                    delete "/api/v1/challenges/1000", format: :json, access_token: access_token.token

                    expect(response).to be_success
                    expect(response.body).to eq 'Error, challenge does not exist'
                end

                it 'and does not remove challenge from the DB' do
                    expect { delete "/api/v1/challenges/1000", format: :json, access_token: access_token.token }.to_not change(Challenge, :count)
                end
            end
        end

        def do_request(options = {})
            delete "/api/v1/challenges/#{challenge.id}", { format: :json }.merge(options)
        end
    end
end