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
        result = user_id == self.user_id && self.white_turn || user_id == self.opponent_id && !self.white_turn ? nil : 'Сейчас не ваш черед ходить'
    end

    def check_cells(from, to)
        result = from == to ? 'Должны быть указаны разные ячейки' : nil
        return result unless result.nil?
        errors = 0
        [from, to].each do |index|
            errors += 1 if %w(a b c d e f g h).index(index[0]).nil?
            errors += 1 if %w(1 2 3 4 5 6 7 8).index(index[1]).nil?
        end
        result = errors > 0 ? 'Указана неправильная ячейка' : nil
    end

    def check_right_figure(from)
        figure = self.board.cells.find_by(x_param: from[0], y_param: from[1]).figure
        result = figure.nil? ? "В клетке '#{from}' нет фигуры для хода" : nil
        return result unless result.nil?
        f_color = figure.color
        result = f_color == 'white' && self.white_turn || f_color == 'black' && !self.white_turn ? nil : 'Нельзя ходить чужой фигурой'
    end

    def check_turn(from, to)
        figure = self.board.cells.find_by(x_param: from[0], y_param: from[1]).figure
        x_params = %w(a b c d e f g h)
        y_params = %w(1 2 3 4 5 6 7 8)
        x_change = x_params.index(to[0]) - x_params.index(from[0])
        y_change = y_params.index(to[1]) - y_params.index(from[1])
        case figure.type
            when 'k'
                result = x_change.abs <= 1 && y_change.abs <= 1 ? nil : 'Неправильный ход королем'
                # добавить рокировку
            when 'q'
                result = x_change != 0 && y_change == 0 || x_change == 0 && y_change != 0 || x_change.abs == y_change.abs ? nil : 'Неправильный ход ферзём'
            when 'r'
                result = x_change != 0 && y_change == 0 || x_change == 0 && y_change != 0 ? nil : 'Неправильный ход ладьёй'
            when 'n'
                result = x_change.abs == 2 && y_change.abs == 1 || x_change.abs == 1 && y_change.abs == 2 ? nil : 'Неправильный ход конём'
            when 'b'
                result = x_change.abs == y_change.abs ? nil : 'Неправильный ход слоном'
            when 'p'
                finish_cell = self.board.cells.find_by(x_param: to[0], y_param: to[1]).figure
                result = figure.color == 'white' && (x_change == 0 && y_change == 1 || x_change == 0 && y_change == 2 && from[1] == '2' || x_change.abs == 1 && y_change == 1 && !finish_cell.nil? && finish_cell.color == 'black') || figure.color == 'black' && (x_change == 0 && y_change == -1 || x_change == 0 && y_change == -2 && from[1] == '7' || x_change.abs == 1 && y_change == -1 && !finish_cell.nil? && finish_cell.color == 'white') ? nil : 'Неправильный ход пешкой'
                # добавить взятие на проходе
        end
        return result unless result.nil?
        unless figure.type == 'n'
            x_direction = x_change > 0 ? 1 : -1
            y_direction = y_change > 0 ? 1 : -1
            checks = []
            if x_change == 0 && y_change.abs > 1
                (y_params.index(from[1]) + y_direction).step(y_params.index(to[1]) - y_direction, y_direction) { |iter| checks.push("#{from[0]}#{iter + 1}") }
            elsif x_change.abs > 1 && y_change == 0
                (x_params.index(from[0]) + x_direction).step(x_params.index(to[0]) - x_direction, x_direction) { |iter| checks.push("#{x_params[iter]}#{from[1]}") }
            elsif x_change.abs == y_change.abs && x_change.abs > 1
                count = x_change.abs - 1
                (1..count).each do |step|
                     x_new = x_params.index(from[0]) + x_direction * step
                     y_new = y_params.index(from[1]) + 1 + y_direction * step
                     checks.push("#{x_params[x_new]}#{y_new}")
                end
            end
            checks.each do |box|
                check = self.board.cells.find_by(x_param: box[0], y_param: box[1]).figure
                result = check.nil? ? nil : 'На пути фигуры есть препятствие'
                break unless result.nil?
            end
        end
        result
    end

    def check_finish_cell(from, to)
        figure = self.board.cells.find_by(x_param: from[0], y_param: from[1]).figure
        obstacle = self.board.cells.find_by(x_param: to[0], y_param: to[1]).figure
        unless obstacle.nil?
            if obstacle.color == figure.color
                result = 'Ваша фигура мешает ходу'
            else
                obstacle.update(cell: nil)
                result = nil
            end
        end   
        result
    end

    private
    def board_build
        Board.build(self)
    end
end
