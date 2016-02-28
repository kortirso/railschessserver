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
        finish_cell = self.board.cells.find_by(x_param: to[0], y_param: to[1]).figure
        x_params = %w(a b c d e f g h)
        y_params = %w(1 2 3 4 5 6 7 8)
        x_change = x_params.index(to[0]) - x_params.index(from[0])
        y_change = y_params.index(to[1]) - y_params.index(from[1])
        p_pass = nil
        roque = nil
        case figure.type
            when 'k'
                result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход королем'
                if !result.nil? && x_change.abs == 2 && y_change == 0
                    if figure.color == 'white'
                        k_place = 'e1'
                        r_place = x_change > 0 ? 'h1' : 'a1'
                    else
                        k_place = 'e8'
                        r_place = x_change > 0 ? 'h8' : 'a8'
                    end
                    did_k_turn = self.turns.where(from: k_place).any?
                    did_r_turn = self.turns.where(from: r_place).any?
                    roque_figure = self.board.cells.find_by(x_param: r_place[0], y_param: r_place[1]).figure
                    result = roque_figure.nil? ? 'Нет ладьи для рокировки' : nil
                    result = result.nil? && did_k_turn && did_r_turn ? 'Нельзя рокироваться, фигуры двигались' : nil
                    roque = roque_figure if result.nil?
                end
            when 'q'
                result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход ферзём'
            when 'r'
                result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход ладьёй'
            when 'n'
                result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход конём'
            when 'b'
                result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход слоном'
            when 'p'
                near_x_param = x_params[x_params.index(from[0]) + x_change]
                near_figure = self.board.cells.find_by(x_param: near_x_param, y_param: from[1]).figure
                if near_figure && near_figure.type == 'p' && near_figure.color != figure.color
                    last_turn = self.turns.last
                    p_pass = near_figure if last_turn.to == "#{near_x_param}#{from[1]}" && last_turn.from == "#{near_x_param}#{from[1].to_i + y_change * 2}"
                end

                result = figure.color == 'white' && (x_change == 0 && y_change == 1 && finish_cell.nil? || x_change == 0 && y_change == 2 && from[1] == '2' && finish_cell.nil? || figure.beaten_fields.include?(to) && !finish_cell.nil? && finish_cell.color == 'black' || figure.beaten_fields.include?(to) && !p_pass.nil?) || figure.color == 'black' && (x_change == 0 && y_change == -1 && finish_cell.nil? || x_change == 0 && y_change == -2 && from[1] == '7' && finish_cell.nil? || figure.beaten_fields.include?(to) && !finish_cell.nil? && finish_cell.color == 'white' || figure.beaten_fields.include?(to) && !p_pass.nil?) ? nil : 'Неправильный ход пешкой'
        end
        return result unless result.nil?
        if figure.type == 'k' && !roque.nil? && x_change.abs > 1 && y_change == 0
            line = roque.cell.y_param
            checks = roque.cell.x_param == 'a' ? ["b#{line}", "c#{line}", "d#{line}"] : ["f#{line}", "g#{line}"]
            check_beated = roque.cell.x_param == 'a' ? ["c#{line}", "d#{line}", "e#{line}"] : ["e#{line}", "f#{line}"]
            checks.each do |box|
                check = self.board.cells.find_by(x_param: box[0], y_param: box[1]).figure
                result = check.nil? ? nil : 'На пути рокировки есть препятствие'
                break unless result.nil?
            end
            if result.nil?
                check_beated.each do |box|
                    self.board.figures.on_the_board.where('color != ?', figure.color).each do |figure|
                        result = figure.beaten_fields.include?(box) ? 'Рокировка под ударом' : nil
                        break unless result.nil?
                    end
                    break unless result.nil?
                end
            end
        end
        return result unless result.nil?
        if !p_pass.nil?
            result = ["#{p_pass.cell.x_param}#{p_pass.cell.y_param}", '0']
        elsif !roque.nil?
            another = roque.cell.x_param == 'a' ? 'd' : 'f'
            result = ["#{roque.cell.x_param}#{roque.cell.y_param}", "#{another}#{roque.cell.y_param}"]
        end
        result
    end

    private
    def board_build
        Board.build(self)
    end
end
