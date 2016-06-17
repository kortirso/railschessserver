class Game < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'
    belongs_to :challenge
    belongs_to :ai

    has_one :board, dependent: :destroy
    has_many :figures, through: :board
    has_many :cells, through: :board
    has_many :turns, dependent: :destroy

    scope :accessable, -> { where(access: true) }
    scope :current, -> { where(game_result: nil) }
    scope :finished, -> { where.not(game_result: nil) }

    before_create :set_ratings
    after_create :board_build

    def checks_before_turn(user_id, from, to)
        result = self.check_users_turn(user_id)
        return result unless result.nil?
        result = self.check_cells(from, to)
        return result unless result.nil?
        result = self.check_right_figure(from)
        return result unless result.nil?
        result = self.check_turn(from, to)
    end

    def check_users_turn(user_id)
        result = user_id == self.user_id && self.white_turn || user_id == self.opponent_id && !self.white_turn ? nil : 'Сейчас не ваш черед ходить'
    end

    def check_cells(from, to)
        result = from == to ? 'Должны быть указаны разные ячейки' : nil
        return result unless result.nil?
        errors = 0
        [from, to].each { |i| errors += 1 if i.size > 2 || !%w(a b c d e f g h).include?(i[0]) || !%w(1 2 3 4 5 6 7 8).include?(i[1]) }
        result = errors > 0 ? 'Указана неправильная ячейка' : nil
    end

    def check_right_figure(from)
        figure = self.cells.find_by(name: from).figure
        result = figure.nil? ? "В клетке '#{from}' нет фигуры для хода" : nil
        return result unless result.nil?
        f_color = figure.color
        result = f_color == 'white' && self.white_turn || f_color == 'black' && !self.white_turn ? nil : 'Нельзя ходить чужой фигурой'
    end

    def is_player?(user_id)
        result = self.user_id == user_id || self.opponent_id == user_id ? true : false
    end

    def self.find_accessable(ident, user_id)
        game = find_by(id: ident)
        if game
            result = game.access == false && !game.is_player?(user_id) ? 'Game is private, you dont have access' : game
        else
            result = 'Game does not exist'
        end
    end

    def self.create_from_challenge(ident, user_id)
        challenge = Challenge.find_by(id: ident)
        if challenge.nil?
            result = 'Challenge does not exist'
        else
            if challenge.user_id == user_id
                result = 'You cant create game against you'
            elsif !challenge.opponent_id.nil? && challenge.opponent_id != user_id
                result = 'You cant create game, challenge is not for you'
            else
                result = Game.build(ident, user_id)
            end
        end
    end

    def self.build(challenge_id, user = nil)
        if challenge_id.nil?
            game = create access: false, guest: user, ai: Ai.find_by(elo: 1)
        else
            challenge = Challenge.find(challenge_id)
            color = case challenge.color
                when 'random' then rand(1)
                when 'white' then 1
                else 0
            end
            game = color == 1 ? create(user_id: challenge.user_id, opponent_id: user, access: challenge.access, challenge_id: challenge_id) : create(user_id: user, opponent_id: challenge.user_id, access: challenge.access, challenge_id: challenge_id)
            game.send_creating_message
            Challenge.del(challenge_id, challenge.user_id)
        end
        game
    end

    def send_creating_message
        game_json = GameSerializer.new(self).serializable_hash.to_json
        PrivatePub.publish_to "/users/#{self.user_id}/games", game: game_json
        PrivatePub.publish_to "/users/#{self.opponent_id}/games", game: game_json
    end

    def check_turn(from, to)
        cells_list = self.cells
        figure = cells_list.find_by(name: from).figure
        finish_cell = cells_list.find_by(name: to).figure
        x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
        x_change, y_change = x_params.index(to[0]) - x_params.index(from[0]), y_params.index(to[1]) - y_params.index(from[1])
        p_pass, roque, result = nil, nil, nil
        is_check = self.white_turn ? self.black_checkmat : self.white_checkmat
        result = self.possibles.include?([from, to]) ? nil : 'Ваш король под угрозой' if is_check == 'check'
        return result unless result.nil?
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
                    roque_figure = cells_list.find_by(name: r_place).figure
                    result = roque_figure.nil? ? 'Нет ладьи для рокировки' : nil
                    result = result.nil? && did_k_turn && did_r_turn ? 'Нельзя рокироваться, фигуры двигались' : nil
                    roque = roque_figure if result.nil?
                end
            when 'q' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход ферзём'
            when 'r' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход ладьёй'
            when 'n' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход конём'
            when 'b' then result = figure.beaten_fields.include?(to) ? nil : 'Неправильный ход слоном'
            when 'p'
                protectors = figure.color == 'white' ? self.w_king_protectors : self.b_king_protectors
                if protectors.include?(figure.cell.name) && x_change == 0 && y_change.abs > 0
                    result = 'Эта пешка защищает короля'
                else
                    near_x_param = x_params[x_params.index(from[0]) + x_change]
                    near_figure = cells_list.find_by(x_param: near_x_param, y_param: from[1]).figure
                    if near_figure && near_figure.type == 'p' && near_figure.color != figure.color
                        last_turn = self.turns.last
                        p_pass = near_figure if last_turn.to == "#{near_x_param}#{from[1]}" && last_turn.from == "#{near_x_param}#{from[1].to_i + y_change * 2}"
                    end
                    result = figure.color == 'white' && (x_change == 0 && y_change == 1 && finish_cell.nil? || x_change == 0 && y_change == 2 && from[1] == '2' && finish_cell.nil? && cells_list.find_by(name: "#{to[0]}#{to[1].to_i - 1}").figure.nil? || figure.beaten_fields.include?(to) && !finish_cell.nil? && finish_cell.color == 'black' || figure.beaten_fields.include?(to) && !p_pass.nil?) || figure.color == 'black' && (x_change == 0 && y_change == -1 && finish_cell.nil? || x_change == 0 && y_change == -2 && from[1] == '7' && finish_cell.nil? && cells_list.find_by(name: "#{to[0]}#{to[1].to_i + 1}").figure.nil? || figure.beaten_fields.include?(to) && !finish_cell.nil? && finish_cell.color == 'white' || figure.beaten_fields.include?(to) && !p_pass.nil?) ? nil : 'Неправильный ход пешкой'
                end
        end
        return result unless result.nil?
        if figure.type == 'k' && !roque.nil? && x_change.abs > 1 && y_change == 0
            line = roque.cell.y_param
            checks = roque.cell.x_param == 'a' ? ["b#{line}", "c#{line}", "d#{line}"] : ["f#{line}", "g#{line}"]
            check_beated = roque.cell.x_param == 'a' ? ["c#{line}", "d#{line}", "e#{line}"] : ["e#{line}", "f#{line}"]
            checks.each do |box|
                check = cells_list.find_by(name: box).figure
                result = check.nil? ? nil : 'На пути рокировки есть препятствие'
                break unless result.nil?
            end
            if result.nil?
                check_beated.each do |box|
                    self.figures.on_the_board.where('color != ?', figure.color).each do |figure|
                        result = figure.beaten_fields.include?(box) ? 'Рокировка под ударом' : nil
                        break unless result.nil?
                    end
                    break unless result.nil?
                end
            end
        end
        return result unless result.nil?
        if !p_pass.nil?
            result = [p_pass.cell.name, '0']
        elsif !roque.nil?
            another = roque.cell.x_param == 'a' ? 'd' : 'f'
            result = [roque.cell.name, "#{another}#{roque.cell.y_param}"]
        elsif figure.type == 'p' && (to[1] == '1' || to[1] == '8')
            result = ['0', "#{figure.color}"]
        end
        result
    end

    def finish_turn
        self.update(white_turn: (self.white_turn ? false : true))
        self.board.check_beaten_fields
        PrivatePub.publish_to "/games/#{self.id}/turns", turn: self.turns.last.to_json
        self.checkmat_check
        self.draw_result(self.offer_draw_by == self.user_id ? self.opponent_id : self.user_id, 0) unless self.offer_draw_by.nil?
        self.ai.turn(self.id) if !self.ai.nil? && self.game_result.nil? && !self.white_turn
    end

    def checkmat_check
        self.white_turn ? self.blacks_check : self.whites_check
    end

    def whites_check
        if self.white_beats.include?(self.figures.find_by(type: 'k', color: 'black').cell.name)
            self.update(white_checkmat: 'check')
            self.automate('black')
        else
            self.update(white_checkmat: nil, possibles: [])
        end
    end

    def blacks_check
        if self.black_beats.include?(self.figures.find_by(type: 'k', color: 'white').cell.name)
            self.update(black_checkmat: 'check')
            self.automate('white')
        else
            self.update(black_checkmat: nil, possibles: [])
        end
    end

    def automate(color)
        king = self.figures.find_by(type: 'k', color: color)
        king_cell = king.cell
        fields, threat_cells = king.beaten_fields, []
        attack = self.figures.on_the_board.other_color(color).attackers
        # удаление бесполезного выхода короля из под шаха (против ферзя, ладьи и слона)
        attack.where.not(type: 'p').each do |f|
            f_cell = f.cell
            x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
            x_change = x_params.index(king_cell.x_param) - x_params.index(f_cell.x_param)
            x_change /= x_change.abs if x_change != 0
            y_change = y_params.index(king_cell.y_param) - y_params.index(f_cell.y_param)
            y_change /= y_change.abs if y_change != 0
            x_new = x_params.index(king_cell.x_param) + x_change
            y_new = y_params.index(king_cell.y_param) + y_change
            fields.delete("#{x_params[x_new]}#{y_params[y_new]}") if (0..7).include?(x_new) && (0..7).include?(y_new)
        end
        king.update(beaten_fields: fields)
        possibles = []
        fields.each { |f| possibles.push([king_cell.name, f]) }
        if attack.count == 1
            defenders = self.figures.on_the_board.where(color: color)
            enemy = attack.first
            enemy_cell = enemy.cell
            # перекрытие ферзя, ладьи и слона
            if %w(q r b).include?(enemy.type)
                x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
                x_enemy, y_enemy = x_params.index(enemy_cell.x_param), y_params.index(enemy_cell.y_param)
                x_change = x_params.index(king_cell.x_param) - x_enemy
                y_change = y_params.index(king_cell.y_param) - y_enemy
                if x_change.abs > 1 || y_change.abs > 1
                    x_diff = x_change != 0 ? x_change / x_change.abs : 0
                    y_diff = y_change != 0 ? y_change / y_change.abs : 0

                    (1..([x_change.abs, y_change.abs].max - 1)).each { |i| threat_cells.push("#{x_params[x_enemy + x_diff * i]}#{y_params[y_enemy + y_diff * i]}") }
                end
            end
            defenders.each do |ally|
                possibles.push([ally.cell.name, enemy_cell.name]) if ally.beaten_fields.include?(enemy_cell.name)
                if ally.type != 'p'
                    threat_cells.each { |threat| possibles.push([ally.cell.name, threat]) if ally.beaten_fields.include?(threat) }
                else
                    change = color == 'white' ? 1 : -1
                    double = (ally.cell.y_param == '7' && ally.color == 'black') || (ally.cell.y_param == '2' && ally.color == 'white') ? 2 : 1
                    (1..double).each do |i|
                        cell_new = "#{ally.cell.x_param}#{ally.cell.y_param.to_i + change * i}"
                        if self.cells.find_by(name: cell_new).figure.nil?
                            possibles.push([ally.cell.name, cell_new]) if threat_cells.include?(cell_new)
                        else
                            break
                        end
                    end
                end
            end
        end
        color == 'white' ? self.complete(0) : self.complete(1) if possibles == []
        self.update(possibles: possibles)
    end

    def offer_draw(player)
        self.update(offer_draw_by: player)
        PrivatePub.publish_to "/games/#{self.id}", game: self.to_json
    end

    def draw_result(player, game_result)
        if self.offer_draw_by != player && (self.user_id == player || self.opponent_id == player)
            if game_result == 1
                self.complete(0.5)
            else
                self.update(offer_draw_by: nil)
                PrivatePub.publish_to "/games/#{self.id}", game: self.to_json
            end
        end
    end

    def complete(game_result)
        case game_result
            when 1 then self.update(white_checkmat: 'mat', game_result: 1)
            when 0 then self.update(black_checkmat: 'mat', game_result: 0)
            when 0.5 then self.update(game_result: 0.5)
        end
        if self.guest.nil?
            user, opponent = self.user, self.opponent
            ra, rb = self.user_rating, self.opponent_rating
            sa, sb = game_result, 1 - game_result
            ea, eb = (1 / (1 + 10 ** ((rb - ra) / 400.0))).round(4), (1 / (1 + 10 ** ((ra - rb) / 400.0))).round(4)
            output = []
            [[ra, ea, sa], [rb, eb, sb]].each do |r|
                if r[0] >= 2400
                    k = 10
                elsif r[0] < 2400 && r[0] >= 2300
                    k = 20
                else
                    k = 40
                end
                output.push(r[0] + k * (r[2] - r[1]))
            end
            user.update(elo: output[0])
            opponent.update(elo: output[1])
        end
        self.figures.removed.destroy_all
        PrivatePub.publish_to "/games/#{self.id}", game: self.to_json
    end

    private
    def set_ratings
        unless self.user.nil?
            self.user_rating = self.user.elo
            self.opponent_rating = self.opponent.elo
        end
    end

    def board_build
        Board.build(self)
    end
end
