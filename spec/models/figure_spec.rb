RSpec.describe Figure, type: :model do
    it { should belong_to :cell }
    it { should validate_inclusion_of(:type).in_array(%w(k q r n b p)) }
    it { should validate_inclusion_of(:color).in_array(%w(white black)) }

    context '.build' do
        before { Figure.build }

        it 'creates 8 white and black P' do
            expect(Figure.where(type: 'p', color: 'white').count).to eq 8
            expect(Figure.where(type: 'p', color: 'black').count).to eq 8
        end

        it 'creates 2 white and black R N B' do
            expect(Figure.where(type: 'r', color: 'white').count).to eq 2
            expect(Figure.where(type: 'r', color: 'black').count).to eq 2

            expect(Figure.where(type: 'n', color: 'white').count).to eq 2
            expect(Figure.where(type: 'n', color: 'black').count).to eq 2

            expect(Figure.where(type: 'b', color: 'white').count).to eq 2
            expect(Figure.where(type: 'b', color: 'black').count).to eq 2
        end

        it 'creates 1 white and black K Q' do
            expect(Figure.where(type: 'k', color: 'white').count).to eq 1
            expect(Figure.where(type: 'k', color: 'black').count).to eq 1

            expect(Figure.where(type: 'q', color: 'white').count).to eq 1
            expect(Figure.where(type: 'q', color: 'black').count).to eq 1
        end
    end
end
