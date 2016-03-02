class Game < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'

    has_one :board
    has_many :turns

    validates :user_id, :opponent_id, presence: true

    scope :accessable, -> { where(access: true) }
    scope :current, -> { where(game_result: nil) }
    scope :finished, -> { where.not(game_result: nil) }

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
        [from, to].each { |index| errors += 1 if index.size > 2 || %w(a b c d e f g h).index(index[0]).nil? || %w(1 2 3 4 5 6 7 8).index(index[1]).nil? }
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
        x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
        x_change = x_params.index(to[0]) - x_params.index(from[0])
        y_change = y_params.index(to[1]) - y_params.index(from[1])
        p_pass, roque = nil, nil
        case figure.type
            when 'k'
                result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход королем'
                if result.nil?
                    protectes = figure.color == 'white' ? figure.board.game.black_protectes : figure.board.game.white_protectes
                    result = protectes.include?(to) ? 'Нельзя атаковать, фигура защищена' : nil
                end
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
            when 'q' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход ферзём'
            when 'r' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход ладьёй'
            when 'n' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход конём'
            when 'b' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход слоном'
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
        protectors = figure.color == 'white' ? self.w_king_protectors : self.b_king_protectors
        if protectors.include?(figure.cell.cell_name)
            king = self.board.figures.find_by(type: 'k', color: figure.color).cell
            x_diff = x_params.index(from[0]) - x_params.index(king.x_param)
            y_diff = y_params.index(from[1]) - y_params.index(king.y_param)
            x = x_diff != 0 ? x_diff / x_diff.abs : 0
            y = y_diff != 0 ? y_diff / y_diff.abs : 0

            if x != 0 && y == 0
                x_new = x_params.index(from[0]) + x
                while x_new >= 0 && x_new <= 7
                    cell = "#{x_params[x_new]}#{from[1]}"
                    field_figure = self.board.cells.find_by(x_param: cell[0], y_param: cell[1]).figure
                    unless field_figure.nil?
                        result = field_figure.color != figure.color && field_figure.type == 'q' || field_figure.type == 'r' ? 'Ход запрещен, эта фигура защищает короля' : nil
                        break
                    end
                    x_new += x
                end
            elsif x == 0 && y != 0
                y_new = y_params.index(from[1]) + y
                while y_new >= 0 && y_new <= 7
                    cell = "#{from[0]}#{y_params[y_new]}"
                    field_figure = self.board.cells.find_by(x_param: cell[0], y_param: cell[1]).figure
                    unless field_figure.nil?
                        result = field_figure.color != figure.color && field_figure.type == 'q' || field_figure.type == 'r' ? 'Ход запрещен, эта фигура защищает короля' : nil
                        break
                    end
                    y_new += y
                end
            else                
                x_new = x_params.index(from[0]) + x
                y_new = y_params.index(from[1]) + y
                while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    cell = "#{x_params[x_new]}#{y_params[y_new]}"
                    field_figure = self.board.cells.find_by(x_param: cell[0], y_param: cell[1]).figure
                    unless field_figure.nil?
                        result = field_figure.color != figure.color && field_figure.type == 'q' || field_figure.type == 'b' ? 'Ход запрещен, эта фигура защищает короля' : nil
                        break
                    end
                    x_new += x
                    y_new += y
                end
            end
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
        elsif figure.type == 'p' && to[1] == '1' || to[1] == '8'
            result = ['0', "#{figure.color}"]
        end
        result
    end

    def beat_fields
        range = [[], [], [], []]
        self.board.figures.on_the_board.each do |figure|
            if figure.color == 'white'
                range[0] += figure.beaten_fields
                range[1] += figure.protected_fields
            else
                range[2] += figure.beaten_fields
                range[3] += figure.protected_fields
            end
        end
        self.update(white_beats: range[0].uniq, white_protectes: range[1].uniq, black_beats: range[2].uniq, black_protectes: range[3].uniq)
    end

    def checkmat_check
        if self.white_turn
            self.blacks_check
            self.whites_check
        else
            self.whites_check
            self.blacks_check
        end
    end

    def whites_check
        if self.white_beats.include?(self.board.figures.find_by(type: 'k', color: 'black').cell.cell_name)
            case self.white_checkmat
                when nil then self.update(white_checkmat: 'check')
                when 'check' then self.update(white_checkmat: 'mat', game_result: 1)
            end
        end
    end

    def blacks_check
        if self.black_beats.include?(self.board.figures.find_by(type: 'k', color: 'white').cell.cell_name)
            case self.black_checkmat
                when nil then self.update(black_checkmat: 'check')
                when 'check' then self.update(black_checkmat: 'mat', game_result: 0)
            end
        end
    end

    private
    def board_build
        Board.build(self)
    end
end
