class Challenge < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'

    has_one :game

    validates :user_id, :color, :access, presence: true
    validates :color, inclusion: { in: %w(random white black) }

    scope :accessable, -> (user) { where('user_id = ? OR opponent_id = ? OR opponent_id IS NULL', user, user) }
end
