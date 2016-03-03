class Figure < ActiveRecord::Base
    self.inheritance_column = nil

    belongs_to :cell
    belongs_to :board

    validates :type, :color, :board_id, :image, presence: true
    validates :type, inclusion: { in: %w(k q r n b p) }
    validates :color, inclusion: { in: %w(white black) }

    scope :on_the_board, -> { where.not(cell: nil) }
    scope :whites, -> { where(color: 'white') }
    scope :blacks, -> { where(color: 'black') }

    def self.build(board)
        %w(white black).each do |color|
            (1..8).each do |number|
                create type: 'p', color: color, board: board, image: "figures/#{color[0]}p.png"
            end
            (1..2).each do |number|
                %w(r n b).each do |type|
                    create type: type, color: color, board: board, image: "figures/#{color[0]}#{type}.png"
                end
            end
            %w(k q).each do |type|
                create type: type, color: color, board: board, image: "figures/#{color[0]}#{type}.png"
            end
        end
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
        unless self.beaten_fields.empty?
            fields = self.color == 'white' ? self.board.game.black_beats : self.board.game.white_beats
            limits = self.beaten_fields - fields
            self.update(beaten_fields: limits) if self.beaten_fields != limits
        end
        fields = []
        x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
        x_index, y_index = x_params.index(self.cell.x_param), y_params.index(self.cell.y_param)
        [-1, 1].each do |x_change|
            [-1, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    cell = "#{x_params[x_new]}#{y_params[y_new]}"
                    field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                    unless field_figure.empty?
                        check_king_protector(self, cell, x_params, y_params) if field_figure[0][1] == self.color
                        break
                    end
                    x_new += x_change
                    y_new += y_change
                end
            end
        end
        [-1, 1].each do |x_change|
            y_change, x_new = 0, x_index + x_change
            while x_new >= 0 && x_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_index]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                unless field_figure.empty?
                    check_king_protector(self, cell, x_params, y_params) if field_figure[0][1] == self.color
                    break
                end
                x_new += x_change
            end
        end
        [-1, 1].each do |y_change|
            x_change, y_new = 0, y_index + y_change
            while y_new >= 0 && y_new <= 7
                cell = "#{x_params[x_index]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                unless field_figure.empty?
                    check_king_protector(self, cell, x_params, y_params) if field_figure[0][1] == self.color
                    break
                end
                y_new += y_change
            end
        end
        if self.color == 'white'
            self.board.game.update(w_king_protectors: fields) if self.board.game.w_king_protectors != fields
        else
            self.board.game.update(b_king_protectors: fields) if self.board.game.b_king_protectors != fields
        end
    end

    def r_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields = [[], []]
        [-1, 1].each do |x_change|
            y_change, x_new = 0, x_index + x_change
            while x_new >= 0 && x_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_index]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                if field_figure.empty?
                    fields[0].push(cell)
                else
                    field_figure[0][1] != color ? fields[0].push(cell) : fields[1].push(cell)
                    break
                end
                x_new += x_change
            end
        end
        [-1, 1].each do |y_change|
            x_change, y_new = 0, y_index + y_change
            while y_new >= 0 && y_new <= 7
                cell = "#{x_params[x_index]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                if field_figure.empty?
                    fields[0].push(cell)
                else
                    field_figure[0][1] != color ? fields[0].push(cell) : fields[1].push(cell)
                    break
                end
                y_new += y_change
            end
        end
        fields
    end

    def n_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields = [[], []]
        [-2, 2].each do |x_change|
            [-1, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    cell = "#{x_params[x_new]}#{y_params[y_new]}"
                    field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                    field_figure.empty? || field_figure[0][1] != color ? fields[0].push(cell) : fields[1].push(cell)
                end
            end
        end
        [-1, 1].each do |x_change|
            [-2, 2].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    cell = "#{x_params[x_new]}#{y_params[y_new]}"
                    field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                    field_figure.empty? || field_figure[0][1] != color ? fields[0].push(cell) : fields[1].push(cell)
                end
            end
        end
        fields
    end

    def b_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields = [[], []]
        [-1, 1].each do |x_change|
            [-1, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    cell = "#{x_params[x_new]}#{y_params[y_new]}"
                    field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                    if field_figure.empty?
                        fields[0].push(cell)
                    else
                        field_figure[0][1] != color ? fields[0].push(cell) : fields[1].push(cell)
                        break
                    end
                    x_new += x_change
                    y_new += y_change
                end
            end
        end
        fields
    end

    def k_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields = [[], []]
        [-1, 0, 1].each do |x_change|
            [-1, 0, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    cell = "#{x_params[x_new]}#{y_params[y_new]}"
                    field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                    field_figure.empty? || field_figure[0][1] != color ? fields[0].push(cell) : fields[1].push(cell)
                end
            end
        end
        fields
    end

    def p_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        fields = [[], []]
        y_change = self.color == 'white' ? 1 : -1
        y_new = y_index + y_change
        [-1, 1].each do |x_change|
            x_new = x_index + x_change
            if x_new >= 0 && x_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                field_figure.empty? || field_figure[0][1] != color ? fields[0].push(cell) : fields[1].push(cell)
            end
        end
        fields
    end

    private
    def check_king_protector(king, from, x_params, y_params)
        x_diff = x_params.index(from[0]) - x_params.index(king.cell.x_param)
        y_diff = y_params.index(from[1]) - y_params.index(king.cell.y_param)
        x = x_diff != 0 ? x_diff / x_diff.abs : 0
        y = y_diff != 0 ? y_diff / y_diff.abs : 0

        if x != 0 && y == 0
            x_new = x_params.index(from[0]) + x
            while x_new >= 0 && x_new <= 7
                cell = "#{x_params[x_new]}#{from[1]}"
                field_figure = king.board.cells.find_by(x_param: cell[0], y_param: cell[1]).figure
                unless field_figure.nil?
                    if field_figure.color != king.color && field_figure.type == 'q' || field_figure.type == 'r'
                        protector = king.board.cells.find_by(x_param: from[0], y_param: from[1]).figure
                        protector.beaten_fields.include?(cell) ? protector.update(beaten_fields: [cell]) : protector.update(beaten_fields: [])
                    end
                    break
                end
                x_new += x
            end
        elsif x == 0 && y != 0
            y_new = y_params.index(from[1]) + y
            while y_new >= 0 && y_new <= 7
                cell = "#{from[0]}#{y_params[y_new]}"
                field_figure = king.board.cells.find_by(x_param: cell[0], y_param: cell[1]).figure
                unless field_figure.nil?
                    if field_figure.color != king.color && field_figure.type == 'q' || field_figure.type == 'r'
                        protector = king.board.cells.find_by(x_param: from[0], y_param: from[1]).figure
                        protector.beaten_fields.include?(cell) ? protector.update(beaten_fields: [cell]) : protector.update(beaten_fields: [])
                    end
                    break
                end
                y_new += y
            end
        else                
            x_new = x_params.index(from[0]) + x
            y_new = y_params.index(from[1]) + y
            while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = king.board.cells.find_by(x_param: cell[0], y_param: cell[1]).figure
                unless field_figure.nil?
                    if field_figure.color != king.color && field_figure.type == 'q' || field_figure.type == 'b'
                        protector = king.board.cells.find_by(x_param: from[0], y_param: from[1]).figure
                        protector.beaten_fields.include?(cell) ? protector.update(beaten_fields: [cell]) : protector.update(beaten_fields: [])
                    end
                    break
                end
                x_new += x
                y_new += y
            end
        end
    end
end
