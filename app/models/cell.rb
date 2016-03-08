class Cell < ActiveRecord::Base
    belongs_to :board
    has_one :figure

    validates :board_id, :x_param, :y_param, :name, presence: true
    validates :x_param, inclusion: { in: %w(a b c d e f g h) }
    validates :y_param, inclusion: { in: %w(1 2 3 4 5 6 7 8) }

    def self.build(board)
        inserts, board_id, t = [], board.id, Time.current
        %w(a b c d e f g h).each do |x|
            %w(1 2 3 4 5 6 7 8).each do |y|
                inserts.push "(#{board_id}, '#{x}', '#{y}', '#{x + y}', '#{t}', '#{t}')"
            end
        end
        Cell.connection.execute "INSERT INTO cells (board_id, x_param, y_param, name, created_at, updated_at) VALUES #{inserts.join(", ")}"
    end
end
