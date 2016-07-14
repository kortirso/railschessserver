RSpec.describe Challenge, type: :model do
    it { should belong_to :user }
    it { should belong_to :opponent }
    it { should have_one :game }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :color }
    it { should validate_presence_of :access }
    it { should validate_inclusion_of(:color).in_array(%w(random white black)) }

    it 'should be valid' do
        challenge = create :challenge

        expect(challenge).to be_valid
    end

    describe 'Methods' do
        context '.build' do

        end

        context '.del' do

        end

        context '.is_player?' do

        end

        context '.can_be_created?' do

        end

        context '.send_creating_message' do

        end

        context '.send_deleting_message' do

        end

        context '.error_compilation' do

        end
    end
end
