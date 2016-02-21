class Turn < ActiveRecord::Base
    belongs_to :game

    validates :game_id, :from, :to, presence: true
end
