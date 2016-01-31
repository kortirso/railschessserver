RSpec.describe Game, type: :model do
    it { should belong_to :user }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :access }
    it { should validate_presence_of :opponent_id }
end
