RSpec.describe Board, type: :model do
    it { should belong_to :game }
    it { should have_many :cells }
    it { should have_many :figures }
    it { should validate_presence_of :game_id }

    describe 'Methods' do
        let!(:user) { create :user }
        let!(:opponent) { create :user }
        let!(:game) { create :game, user: user, opponent: opponent }

        context '.build' do
            it 'should create new Board' do
                expect { Board.build(game) }.to change(Board, :count).by(1)
            end

            it 'and it belongs_to game' do
                board = Board.build(game)

                expect(game.board).to eq board
            end
        end

        context '.set_figures' do
            let(:board) { create :board, game: game }
            before do
                Cell.build(board)
                Figure.build(board)
                board.set_figures
            end

            it 'set 8 white Pawns at 2 line' do
                %w(a b c d e f g h).each do |x|
                    expect(Cell.find_by(name: "#{x}2").figure.type).to eq 'p'
                    expect(Cell.find_by(name: "#{x}2").figure.color).to eq 'white'
                end
            end

            it 'set 8 black Pawns at 7 line' do
                %w(a b c d e f g h).each do |x|
                    expect(Cell.find_by(name: "#{x}7").figure.type).to eq 'p'
                    expect(Cell.find_by(name: "#{x}7").figure.color).to eq 'black'
                end
            end

            it 'set 2 white Rooks at 1 line' do
                %w(a h).each do |x|
                    expect(Cell.find_by(name: "#{x}1").figure.type).to eq 'r'
                    expect(Cell.find_by(name: "#{x}1").figure.color).to eq 'white'
                end
            end

            it 'set 2 black Rooks at 8 line' do
                %w(a h).each do |x|
                    expect(Cell.find_by(name: "#{x}8").figure.type).to eq 'r'
                    expect(Cell.find_by(name: "#{x}8").figure.color).to eq 'black'
                end
            end

            it 'set 2 white kNights at 1 line' do
                %w(b g).each do |x|
                    expect(Cell.find_by(name: "#{x}1").figure.type).to eq 'n'
                    expect(Cell.find_by(name: "#{x}1").figure.color).to eq 'white'
                end
            end

            it 'set 2 black kNights at 8 line' do
                %w(b g).each do |x|
                    expect(Cell.find_by(name: "#{x}8").figure.type).to eq 'n'
                    expect(Cell.find_by(name: "#{x}8").figure.color).to eq 'black'
                end
            end

            it 'set 2 white Bishops at 1 line' do
                %w(c f).each do |x|
                    expect(Cell.find_by(name: "#{x}1").figure.type).to eq 'b'
                    expect(Cell.find_by(name: "#{x}1").figure.color).to eq 'white'
                end
            end

            it 'set 2 black Bishops at 8 line' do
                %w(c f).each do |x|
                    expect(Cell.find_by(name: "#{x}8").figure.type).to eq 'b'
                    expect(Cell.find_by(name: "#{x}8").figure.color).to eq 'black'
                end
            end

            it 'set 2 Kings at E line' do
                %w(1 8).each do |y|
                    expect(Cell.find_by(name: "e#{y}").figure.type).to eq 'k'
                end
            end

            it 'set 2 Queens at D line' do
                %w(1 8).each do |y|
                    expect(Cell.find_by(name: "d#{y}").figure.type).to eq 'q'
                end
            end
        end
    end
end
