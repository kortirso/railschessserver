RSpec.describe Turn, type: :model do
    it { should belong_to :game }
    it { should validate_presence_of :game_id }
    it { should validate_presence_of :from }
    it { should validate_presence_of :to }
end
