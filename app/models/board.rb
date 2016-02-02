class Board < ActiveRecord::Base
    belongs_to :game
    has_many :cells

    validates :game_id, presence: true

    def self.build(game)
        board = create game: game
        Cell.build(board)
        Figure.build
        #board.set_figures
        board
    end

    def set_figures
        
    end
end
