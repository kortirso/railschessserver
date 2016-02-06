class Game < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'

    has_one :board

    validates :user_id, :opponent_id, presence: true

    scope :accessable, -> { where(access: true) }

    after_create :board_build

    def self.build(user_1, user_2, access)
        game = create user_id: user_1, opponent_id: user_2, access: access
    end

    private
    def board_build
        Board.build(self)
    end
end
