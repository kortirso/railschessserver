class Game < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'

    has_one :board
    has_many :turns

    validates :user_id, :opponent_id, presence: true

    scope :accessable, -> { where(access: true) }

    after_create :board_build

    def self.build(user_1, user_2, access)
        game = create user_id: user_1, opponent_id: user_2, access: access
    end

    def check_users_turn(user_id)
        result = user_id == self.user_id && self.white_turn || user_id == self.opponent_id && !self.white_turn ? nil : "Сейчас не ваш черед ходить"
    end

    def check_cells(from, to)
        result = from == to ? "Должны быть указаны разные ячейки" : nil
        return result unless result.nil?
        errors = 0
        %w("#{from} #{to}").each do |index|
            case index[0]
                when 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'
                else errors += 1
            end
            case index[1]
                when '1', '2', '3', '4', '5', '6', '7', '8'
                else errors += 1
            end
        end
        result = errors > 0 ? "Указана неправильная ячейка" : nil
    end

    def check_right_figure(from)
        figure = self.board.cells.find_by(x_param: from[0], y_param: from[1]).figure
        result = figure.nil? ? "В клетке '#{from}' нет фигуры для хода" : nil
        return result unless result.nil?
        f_color = figure.color
        result = f_color == 'white' && self.white_turn || f_color == 'black' && !self.white_turn ? nil : "Нельзя ходить чужой фигурой"
    end

    private
    def board_build
        Board.build(self)
    end
end
