RSpec.describe Game, type: :model do
    it { should belong_to :user }
    it { should belong_to :opponent }
    it { should have_one :board }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :access }
    it { should validate_presence_of :opponent_id }

    context '.build' do
        let(:user_1) { create :user }
        let(:user_2) { create :user }

        it 'should creates new Game' do
            expect { Game.build(user_1, user_2, true) }.to change(Game, :count).by(1)
        end

        it 'user_1 is owner, user_2 is opponent and game is opened' do
            game = Game.build(user_1, user_2, true)

            expect(user_1.games.first).to eq game
            expect(user_2.as_opponent_games.first).to eq game
            expect(game.access).to eq true
        end

        it 'and creates new Board' do
            expect { Game.build(user_1, user_2, true) }.to change(Board, :count).by(1)
        end

        it 'and creates new 32 Figures' do
            expect { Game.build(user_1, user_2, true) }.to change(Figure, :count).by(32)
        end
    end
end
