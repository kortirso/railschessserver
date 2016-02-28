class Figure < ActiveRecord::Base
    self.inheritance_column = nil

    belongs_to :cell
    belongs_to :board

    validates :type, :color, :board_id, :image, presence: true
    validates :type, inclusion: { in: %w(k q r n b p) }
    validates :color, inclusion: { in: %w(white black) }

    scope :on_the_board, -> { where.not(cell: nil) }

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

    def check_beaten_fields
        x_params, y_params = %w(a b c d e f g h), %w(1 2 3 4 5 6 7 8)
        x_index, y_index = x_params.index(self.cell.x_param), y_params.index(self.cell.y_param)
        beaten_fields = case self.type
            when 'k' then k_like_check(x_params, y_params, x_index, y_index)
            when 'q' then r_like_check(x_params, y_params, x_index, y_index) + b_like_check(x_params, y_params, x_index, y_index)
            when 'r' then r_like_check(x_params, y_params, x_index, y_index)
            when 'n' then n_like_check(x_params, y_params, x_index, y_index)
            when 'b' then b_like_check(x_params, y_params, x_index, y_index)
            when 'p' then p_like_check(x_params, y_params, x_index, y_index)
        end
        self.update(beaten_fields: beaten_fields)
    end

    def r_like_check(x_params, y_params, x_index, y_index)
        beaten_fields = []
        [-1, 1].each do |x_change|
            y_change, x_new = 0, x_index + x_change
            while x_new >= 0 && x_new <= 7
                field_figure = self.board.cells.find_by(x_param: x_params[x_new], y_param: self.cell.y_param).figure
                if field_figure.nil?
                    beaten_fields.push("#{x_params[x_new]}#{self.cell.y_param}")
                else
                    beaten_fields.push("#{x_params[x_new]}#{self.cell.y_param}") if field_figure.color != self.color
                    break
                end
                x_new += x_change
            end
        end
        [-1, 1].each do |y_change|
            x_change, y_new = 0, y_index + y_change
            while y_new >= 0 && y_new <= 7
                field_figure = self.board.cells.find_by(x_param: self.cell.x_param, y_param: y_params[y_new]).figure
                if field_figure.nil?
                    beaten_fields.push("#{self.cell.x_param}#{y_params[y_new]}")
                else
                    beaten_fields.push("#{self.cell.x_param}#{y_params[y_new]}") if field_figure.color != self.color
                    break
                end
                y_new += y_change
            end
        end
        beaten_fields
    end

    def n_like_check(x_params, y_params, x_index, y_index)
        beaten_fields = []
        [-2, 2].each do |x_change|
            [-1, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                beaten_fields.push(n_common_block(x_params, y_params, x_new, y_new))
            end
        end
        [-1, 1].each do |x_change|
            [-2, 2].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                beaten_fields.push(n_common_block(x_params, y_params, x_new, y_new))
            end
        end
        beaten_fields.compact
    end

    def n_common_block(x_params, y_params, x_new, y_new)
        if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
            field_figure = self.board.cells.find_by(x_param: x_params[x_new], y_param: y_params[y_new]).figure
            result = "#{x_params[x_new]}#{y_params[y_new]}" if field_figure.nil? || field_figure.color != self.color
        end
        result
    end

    def b_like_check(x_params, y_params, x_index, y_index)
        beaten_fields = []
        [-1, 1].each do |x_change|
            [-1, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                while x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    field_figure = self.board.cells.find_by(x_param: x_params[x_new], y_param: y_params[y_new]).figure
                    if field_figure.nil?
                        beaten_fields.push("#{x_params[x_new]}#{y_params[y_new]}")
                    else
                        beaten_fields.push("#{x_params[x_new]}#{y_params[y_new]}") if field_figure.color != self.color
                        break
                    end
                    x_new += x_change
                    y_new += y_change
                end
            end
        end
        beaten_fields
    end

    def k_like_check(x_params, y_params, x_index, y_index)
        beaten_fields = []
        [-1, 0, 1].each do |x_change|
            [-1, 0, 1].each do |y_change|
                x_new, y_new = x_index + x_change, y_index + y_change
                if x_new >= 0 && x_new <= 7 && y_new >= 0 && y_new <= 7
                    field_figure = self.board.cells.find_by(x_param: x_params[x_new], y_param: y_params[y_new]).figure
                    beaten_fields.push("#{x_params[x_new]}#{y_params[y_new]}") if field_figure.nil? || field_figure.color != self.color
                end
            end
        end
        beaten_fields
    end

    def p_like_check(x_params, y_params, x_index, y_index)
        beaten_fields = []
        y_change = self.color == 'white' ? 1 : -1
        y_new = y_index + y_change
        [-1, 1].each do |x_change|
            x_new = x_index + x_change
            if x_new >= 0 && x_new <= 7
                field_figure = self.board.cells.find_by(x_param: x_params[x_new], y_param: y_params[y_new]).figure
                beaten_fields.push("#{x_params[x_new]}#{y_params[y_new]}") if field_figure.nil? || field_figure.color != self.color
            end
        end
        beaten_fields
    end
end
