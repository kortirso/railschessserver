RSpec.describe Cell, type: :model do
    it { should belong_to :board }
    it { should have_one :figure }
    it { should validate_presence_of :board_id }
    it { should validate_presence_of :x_param }
    it { should validate_presence_of :y_param }
    it { should validate_presence_of :name }
    it { should validate_inclusion_of(:x_param).in_array(%w(a b c d e f g h)) }
    it { should validate_inclusion_of(:y_param).in_array(%w(1 2 3 4 5 6 7 8)) }

    it 'should be valid' do
        cell = create :cell

        expect(cell).to be_valid
    end

    context '.build' do
        let!(:board) { create :board }

        it 'should create new 64 Cells fo Board' do
            expect { Cell.build(board) }.to change(Cell, :count).by(64)
        end
    end
end
