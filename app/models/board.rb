class Board < ActiveRecord::Base
    belongs_to :game
    has_many :cells

    validates :game_id, presence: true
end
