RSpec.describe Cell, type: :model do
    it { should belong_to :board }
    it { should have_one :figure }
    it { should validate_presence_of :board_id }
    it { should validate_presence_of :x_param }
    it { should validate_presence_of :y_param }
    it { should validate_inclusion_of(:x_param).in_array(%w(a b c d e f g h)) }
    #it { should validate_inclusion_of(:y_param).in_range(1..8) }
end
