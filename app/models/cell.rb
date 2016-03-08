class Cell < ActiveRecord::Base
    belongs_to :board
    has_one :figure

    validates :board_id, :x_param, :y_param, presence: true
    validates :x_param, inclusion: { in: %w(a b c d e f g h) }
    validates :y_param, inclusion: { in: %w(1 2 3 4 5 6 7 8) }

    def self.build(board)
        ActiveRecord::Base.transaction do
            %w(a b c d e f g h).each do |x|
                %w(1 2 3 4 5 6 7 8).each do |y|
                    create board: board, x_param: x, y_param: y, name: "#{x + y}"
                end
            end
        end
    end
end
