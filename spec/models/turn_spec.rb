RSpec.describe Turn, type: :model do
    it { should belong_to :game }
    it { should validate_presence_of :game_id }
    it { should validate_presence_of :from }
    it { should validate_presence_of :to }

    it 'should be valid' do
        turn = create :turn

        expect(turn).to be_valid
    end

    describe 'Methods' do
        context '.build' do

        end
    end
end
