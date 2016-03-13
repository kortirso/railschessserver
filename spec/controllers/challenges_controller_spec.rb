RSpec.describe ChallengesController, type: :controller do
    describe 'POST #create' do
        context 'Unauthorized user' do
            it 'cant create challenges' do
                expect { post :create, challenge: {opponent_id: '', access: '1', color: 'random'}, format: :js }.to_not change(Challenge, :count)
            end
        end

        context 'Authorized user' do
            sign_in_user

            context 'for all users' do
                it 'can create challenges' do
                    expect { post :create, challenge: {opponent_id: '', access: '1', color: 'random'}, format: :js }.to change(Challenge, :count).by(1)
                end

                it_behaves_like 'Publishable' do
                    let(:path) { "/users/challenges" }
                    let(:object) { post :create, challenge: {opponent_id: '', access: '1', color: 'random'}, format: :js }
                end
            end

            context 'for current users' do
                let!(:opponent) { create :user }

                it 'can create challenges' do
                    expect { post :create, challenge: {opponent_id: "#{opponent.id}", access: '1', color: 'random'}, format: :js }.to change(Challenge, :count).by(1)
                end
            end
        end
    end

    describe 'DELETE #destroy' do
        let!(:challenge) { create :challenge }

        context 'Unauthorized user' do
            it 'cant destroy challenges' do
                expect { delete :destroy, id: challenge, format: :js }.to_not change(Challenge, :count)
            end
        end

        context 'Authorized user' do
            sign_in_user
            let!(:users_challenge) { create :challenge, user: @current_user }

            it 'can destroy his challenges' do
                expect { delete :destroy, id: users_challenge, format: :js }.to change(Challenge, :count).by(-1)
            end

            it 'cant destroy challenges of other users' do
                expect { delete :destroy, id: challenge, format: :js }.to_not change(Challenge, :count)
            end
        end
    end
end
