RSpec.describe Identity, type: :model do
    it { should belong_to :user }
    it { should validate_presence_of :provider }
    it { should validate_presence_of :uid }
    it { should validate_presence_of :user_id }

    context 'should be valid' do
        it 'with facebook' do
            identity = create :identity, :facebook

            expect(identity).to be_valid
        end

        it 'with vkontakte' do
            identity = create :identity, :vk

            expect(identity).to be_valid
        end
    end
end
