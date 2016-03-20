RSpec.describe Ai, type: :model do
    it { should have_many :games }
    it { should validate_presence_of :elo }

    it 'should be valid' do
        ai = create :ai

        expect(ai).to be_valid
    end

    describe 'Methods' do
        context '.turn' do

        end
    end
end
