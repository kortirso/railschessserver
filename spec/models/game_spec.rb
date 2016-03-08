RSpec.describe Game, type: :model do
    it { should belong_to :user }
    it { should belong_to :opponent }
    it { should belong_to :challenge }
    it { should have_one :board }
    it { should have_many :turns }
    it { should validate_presence_of :opponent_id }

    it 'should be valid' do
        game = create :game

        expect(game).to be_valid
    end

    context '.build' do
        let(:user_1) { create :user }
        let(:user_2) { create :user }

        it 'should creates new Game' do
            expect { Game.build(user_1.id, user_2.id, true, nil) }.to change(Game, :count).by(1)
        end

        it 'user_1 is owner, user_2 is opponent and game is opened' do
            game = Game.build(user_1.id, user_2.id, true, nil)

            expect(user_1.games.first).to eq game
            expect(user_2.as_opponent_games.first).to eq game
            expect(game.access).to eq true
        end

        it 'and creates new Board' do
            expect { Game.build(user_1.id, user_2.id, true, nil) }.to change(Board, :count).by(1)
        end

        it 'and creates new 32 Figures' do
            expect { Game.build(user_1.id, user_2.id, true, nil) }.to change(Figure, :count).by(32)
        end
    end
end
