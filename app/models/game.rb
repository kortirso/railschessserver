class Game < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User'

    has_one :board

    validates :user_id, :opponent_id, :access, presence: true
end
