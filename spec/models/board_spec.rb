RSpec.describe Board, type: :model do
    it { should belong_to :game }
    it { should validate_presence_of :game_id }
end
