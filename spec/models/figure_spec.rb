RSpec.describe Figure, type: :model do
    it { should belong_to :cell }
    it { should belong_to :board }
    it { should validate_presence_of :board_id }
    it { should validate_presence_of :color }
    it { should validate_presence_of :type }
    it { should validate_presence_of :image }
    it { should validate_inclusion_of(:type).in_array(%w(k q r n b p)) }
    it { should validate_inclusion_of(:color).in_array(%w(white black)) }

    it 'should be valid' do
        figure = create :figure

        expect(figure).to be_valid
    end

    describe 'Methods' do
        context '.cell_name' do

        end

        context '.build' do
            let!(:board) { create :board }
            before do
                board.figures.destroy_all
                Figure.build(board)
            end

            it 'creates 8 white and black P' do
                expect(board.figures.where(type: 'p', color: 'white').count).to eq 8
                expect(board.figures.where(type: 'p', color: 'black').count).to eq 8
            end

            it 'creates 2 white and black R N B' do
                expect(board.figures.where(type: 'r', color: 'white').count).to eq 2
                expect(board.figures.where(type: 'r', color: 'black').count).to eq 2

                expect(board.figures.where(type: 'n', color: 'white').count).to eq 2
                expect(board.figures.where(type: 'n', color: 'black').count).to eq 2

                expect(board.figures.where(type: 'b', color: 'white').count).to eq 2
                expect(board.figures.where(type: 'b', color: 'black').count).to eq 2
            end

            it 'creates 1 white and black K Q' do
                expect(board.figures.where(type: 'k', color: 'white').count).to eq 1
                expect(board.figures.where(type: 'k', color: 'black').count).to eq 1

                expect(board.figures.where(type: 'q', color: 'white').count).to eq 1
                expect(board.figures.where(type: 'q', color: 'black').count).to eq 1
            end
        end

        context '.check_beaten_fields' do

        end

        context '.check_king_cells' do

        end

        context '.r_like_check' do

        end

        context '.n_like_check' do

        end

        context '.b_like_check' do

        end

        context '.k_like_check' do

        end

        context '.p_like_check' do

        end

        context '.check_king_protector' do

        end
    end
end
