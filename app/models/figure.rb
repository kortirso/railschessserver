class Figure < ActiveRecord::Base
    self.inheritance_column = nil

    belongs_to :cell
    belongs_to :board

    validates :type, :color, :board_id, presence: true
    validates :type, inclusion: { in: %w(k q r n b p) }
    validates :color, inclusion: { in: %w(white black) }

    def self.build(board)
        %w(white black).each do |color|
            (1..8).each do |number|
                create type: 'p', color: color, board: board
            end
            (1..2).each do |number|
                %w(r n b).each do |type|
                    create type: type, color: color, board: board
                end
            end
            %w(k q).each do |type|
                create type: type, color: color, board: board
            end
        end
    end
end
