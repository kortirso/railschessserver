RSpec.describe Figure, type: :model do
    it { should belong_to :cell }
    it { should validate_inclusion_of(:type).in_array(%w(k q r n b p)) }
    it { should validate_inclusion_of(:color).in_array(%w(white black)) }
end
