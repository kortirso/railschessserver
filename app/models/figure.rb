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
        x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
        x_index, y_index = x_params.index(self.cell.x_param), y_params.index(self.cell.y_param)
        beaten_fields = case self.type
            when 'k' then k_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'q' then r_like_check(board_figures, x_params, y_params, x_index, y_index, self.color) + b_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'r' then r_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'n' then n_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'b' then b_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
            when 'p' then p_like_check(board_figures, x_params, y_params, x_index, y_index, self.color)
        end
        self.update(beaten_fields: beaten_fields) if self.beaten_fields != beaten_fields
    end

    def check_king_cells
        fields = self.color == 'white' ? self.board.game.black_beats : self.board.game.white_beats
        limits = self.beaten_fields - fields
        self.update(beaten_fields: limits) if self.beaten_fields != limits
    end

    def r_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        beaten_fields = []
        [-1, 1].each do |x_change|
            y_change, x_new = 0, x_index + x_change
            while x_new >= 0 && x_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_index]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                if field_figure.empty?
                    beaten_fields.push(cell)
                else
                    beaten_fields.push(cell) if field_figure[0][1] != color
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
                    beaten_fields.push(cell)
                else
                    beaten_fields.push(cell) if field_figure[0][1] != color
                    break
                end
                y_new += y_change
            end
        end
        beaten_fields
    end

    def n_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        beaten_fields = []
        [-2, 2].each do |x_change|
            [-1, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                beaten_fields.push(n_common_block(board_figures, x_params, y_params, x_new, y_new, color))
            end
        end
        [-1, 1].each do |x_change|
            [-2, 2].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                beaten_fields.push(n_common_block(board_figures, x_params, y_params, x_new, y_new, color))
            end
        end
        beaten_fields.compact
    end

    def n_common_block(board_figures, x_params, y_params, x_new, y_new, color)
        if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
            cell = "#{x_params[x_new]}#{y_params[y_new]}"
            field_figure = board_figures.find_all{ |elem| elem[0] == cell }
            result = cell if field_figure.empty? || field_figure[0][1] != color
        end
        result
    end

    def b_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        beaten_fields = []
        [-1, 1].each do |x_change|
            [-1, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    cell = "#{x_params[x_new]}#{y_params[y_new]}"
                    field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                    if field_figure.empty?
                        beaten_fields.push(cell)
                    else
                        beaten_fields.push(cell) if field_figure[0][1] != color
                        break
                    end
                    x_new += x_change
                    y_new += y_change
                end
            end
        end
        beaten_fields
    end

    def k_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        beaten_fields = []
        [-1, 0, 1].each do |x_change|
            [-1, 0, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    cell = "#{x_params[x_new]}#{y_params[y_new]}"
                    field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                    beaten_fields.push(cell) if field_figure.empty? || field_figure[0][1] != color
                end
            end
        end
        beaten_fields
    end

    def p_like_check(board_figures, x_params, y_params, x_index, y_index, color)
        beaten_fields = []
        y_change = self.color == 'white' ? 1 : -1
        y_new = y_index + y_change
        [-1, 1].each do |x_change|
            x_new = x_index + x_change
            if x_new >= 0 && x_new <= 7
                cell = "#{x_params[x_new]}#{y_params[y_new]}"
                field_figure = board_figures.find_all{ |elem| elem[0] == cell }
                beaten_fields.push(cell) if field_figure.empty? || field_figure[0][1] != color
            end
        end
        beaten_fields
    end
end
