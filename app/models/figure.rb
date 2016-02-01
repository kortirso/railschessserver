class Figure < ActiveRecord::Base
    belongs_to :cell

    validates :type, :color, presence: true
    validates :type, inclusion: { in: %w(k q r n b p) }
    validates :color, inclusion: { in: %w(white black) }
end
