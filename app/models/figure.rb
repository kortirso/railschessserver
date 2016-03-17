class Figure < ActiveRecord::Base
    self.inheritance_column = nil

    belongs_to :cell
    belongs_to :board

    validates :type, :color, :board_id, :image, presence: true
    validates :type, inclusion: { in: %w(k q r n b p) }
    validates :color, inclusion: { in: %w(white black) }

    scope :on_the_board, -> { where.not(cell: nil) }
    scope :removed, -> { where(cell: nil) }
    scope :whites, -> { where(color: 'white') }
    scope :blacks, -> { where(color: 'black') }
    scope :current_color, -> (color) { where(color: color) }
    scope :other_color, -> (color) { where.not(color: color) }
    scope :attackers, -> { where(attack: true) } # атакующие короля

    def self.build(board)
        inserts, board_id, t = [], board.id, Time.current
        %w(white black).each do |color|
            8.times do
                inserts.push "(#{board_id}, 'p', '#{color}', 'figures/#{color[0]}p.png', '#{t}', '#{t}')"
            end
            2.times do
                %w(r n b).each do |type|
                    inserts.push "(#{board_id}, '#{type}', '#{color}', 'figures/#{color[0]}#{type}.png', '#{t}', '#{t}')"
                end
            end
            %w(k q).each do |type|
                inserts.push "(#{board_id}, '#{type}', '#{color}', 'figures/#{color[0]}#{type}.png', '#{t}', '#{t}')"
            end
        end
        Figure.connection.execute "INSERT INTO figures (board_id, type, color, image, created_at, updated_at) VALUES #{inserts.join(", ")}"
    end

    def check_beaten_fields(board_figures)
        fields = [[], []]
        x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
        x_index, y_index = x_params.index(self.cell.x_param), y_params.index(self.cell.y_param)
        fields = case self.type
            when 'k' then k_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'q'
                r_check = r_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
                b_check = b_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
                [r_check[0] + b_check[0], r_check[1] + b_check[1] ]
            when 'r' then r_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'n' then n_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'b' then b_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'p' then p_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
        end
        self.update(beaten_fields: fields[0]) if self.beaten_fields != fields[0]
        self.update(protected_fields: fields[1]) if self.protected_fields != fields[1]
    end

    def check_king_cells(board_figures)
        current_game = self.board.game
        unless self.beaten_fields.empty?
            fields = self.color == 'white' ? current_game.black_beats : current_game.white_beats
            limits = self.beaten_fields - fields
            self.update(beaten_fields: limits) if self.beaten_fields != limits
        end
        fields = []
        x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
        x_index, y_index = x_params.index(self.cell.x_param), y_params.index(self.cell.y_param)
        [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]].each do |turn|
            x_change, y_change = turn[0], turn[1]
            x_new, y_new = x_index + x_change, y_index + y_change
            while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                unless field_figure.empty?
                    fields.push(check_king_protector(self, cell, x_params, y_params, board_figures)) if field_figure[0][1] == self.color
                    break
                end
                x_new += x_change
                y_new += y_change
            end
        end
        if self.color == 'white'
            current_game.update(w_king_protectors: fields) if current_game.w_king_protectors != fields.compact!
        else
            current_game.update(b_king_protectors: fields) if current_game.b_king_protectors != fields.compact!
        end

        fields = []
        protectes = self.color == 'white' ? current_game.black_protectes : current_game.white_protectes
        self.beaten_fields.each do |cell|
            fields.push(cell) unless protectes.include?(cell)
        end
        self.update(beaten_fields: fields) if self.beaten_fields != fields
    end

    def r_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields, attack = [[], []], false
        [[-1, 0], [1, 0], [0, -1], [0, 1]].each do |turn|
            x_change, y_change = turn[0], turn[1]
            x_new, y_new = x_index + x_change, y_index + y_change
            while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                if field_figure.empty?
                    fields[0].push(cell)
                else
                    if field_figure[0][1] != color
                        fields[0].push(cell)
                        attack = true if self.board.cells.find_by(name: cell).figure.type == 'k'
                    else
                        fields[1].push(cell)
                    end
                    break
                end
                x_new += x_change
                y_new += y_change
            end
        end
        self.update(attack: attack)
        fields
    end

    def n_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields, attack = [[], []], false
        [[-2, -1], [-2, 1], [2, -1], [2, 1], [-1, -2], [-1, 2], [1, -2], [1, 2]].each do |turn|
            x_change, y_change = turn[0], turn[1]
            x_new, y_new = x_index + x_change, y_index + y_change
            if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                if field_figure.empty?
                    fields[0].push(cell)
                else
                    if field_figure[0][1] != color
                        fields[0].push(cell)
                        attack = true if self.board.cells.find_by(name: cell).figure.type == 'k'
                    else
                        fields[1].push(cell)
                    end
                end
            end
        end
        self.update(attack: attack)
        fields
    end

    def b_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields, attack = [[], []], false
        [[-1, -1], [-1, 1], [1, -1], [1, 1]].each do |turn|
            x_change, y_change = turn[0], turn[1]
            x_new, y_new = x_index + x_change, y_index + y_change
            while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                if field_figure.empty?
                    fields[0].push(cell)
                else
                    if field_figure[0][1] != color
                        fields[0].push(cell)
                        attack = true if self.board.cells.find_by(name: cell).figure.type == 'k'
                    else
                        fields[1].push(cell)
                    end
                    break
                end
                x_new += x_change
                y_new += y_change
            end
        end
        self.update(attack: attack) unless self.type == 'q' && self.attack
        fields
    end

    def k_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields = [[], []]
        [[-1, -1], [-1, 0], [-1, 1], [0, -1], [0, 1], [1, -1], [1, 0], [1, 1]].each do |turn|
            x_change, y_change = turn[0], turn[1]
            x_new, y_new = x_index + x_change, y_index + y_change
            if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                field_figure.empty? || field_figure[0][1] != color ? fields[0].push(cell) : fields[1].push(cell)
            end
        end
        fields
    end

    def p_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields, attack = [[], []], false
        y_change = self.color == 'white' ? 1 : -1
        y_new = y_index + y_change
        [-1, 1].each do |x_change|
            x_new = x_index + x_change
            if x_new >= 0 && x_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                if field_figure.empty?
                    fields[0].push(cell)
                else
                    if field_figure[0][1] != color
                        fields[0].push(cell)
                        attack = true if self.board.cells.find_by(name: cell).figure.type == 'k'
                    else
                        fields[1].push(cell)
                    end
                end
            end
        end
        self.update(attack: attack)
        fields
    end

    private
    def check_king_protector(king, from, x_params, y_params, board_figures)
        x_diff = x_params.index(from[0]) - x_params.index(king.cell.x_param)
        y_diff = y_params.index(from[1]) - y_params.index(king.cell.y_param)
        x = x_diff != 0 ? x_diff / x_diff.abs : 0
        y = y_diff != 0 ? y_diff / y_diff.abs : 0
        x_new, y_new, protector = x_params.index(from[0]) + x, y_params.index(from[1]) + y, nil
        cells_list = king.board.cells
        while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
            cell = "#{x_params[x_new]}#{y_params[y_new]}"
            field_figure = board_figures.find_all{ |elem| elem[0] == cell }
            unless field_figure.empty?
                additional = x != 0 && y != 0 ? 'b' : 'r'
                figure = cells_list.find_by(name: cell).figure
                if figure.color != king.color && (figure.type == 'q' || figure.type == additional)
                    protector = cells_list.find_by(name: from).figure
                    protector.beaten_fields.include?(cell) ? protector.update(beaten_fields: [cell]) : protector.update(beaten_fields: [])
                end
                break
            end
            x_new += x
            y_new += y
        end
        result = protector.nil? ? nil : from
    end
end
