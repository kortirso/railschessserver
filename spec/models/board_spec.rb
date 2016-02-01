RSpec.describe Board, type: :model do
    it { should belong_to :game }
    it { should have_many :cells }
    it { should validate_presence_of :game_id }

    context '.build' do
        let(:game) { create :game }

        it 'should create new Board' do
            expect { Board.build(game) }.to change(Board, :count).by(1)
        end

        it 'and it belongs_to game' do
            board = Board.build(game)

            expect(game.board).to eq board
        end
    end
end
