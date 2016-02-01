class Cell < ActiveRecord::Base
    belongs_to :board

    validates :board_id, :x_param, :y_param, presence: true
    validates :x_param, inclusion: { in: %w(a b c d e f g h) }
    validates :y_param, inclusion: { in: 1..8 }
end
