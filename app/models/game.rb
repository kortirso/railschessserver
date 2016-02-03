class Game < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'

    has_one :board

    validates :user_id, :opponent_id, :access, presence: true

    after_create :board_build

    def self.build(user_1, user_2, access)
        game = create user: user_1, opponent: user_2, access: access
    end

    private
    def board_build
        Board.build(self)
    end
end
