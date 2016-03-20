class Ai < ActiveRecord::Base
    has_many :games

    validates :elo, presence: true

    def turn(game_id)
        game, result = Game.find(game_id), []
        if game.possibles == []
            figures = game.figures.on_the_board.blacks.to_ary
            figures.each { |figure| result.push(figure) unless figure.beaten_fields == [] }
            turn_error, rand_figure, rand_turn = 'ERROR', nil, nil
            while turn_error.is_a? String
                rand_figure = result[rand(result.size - 1)]
                fields = rand_figure.beaten_fields
                if rand_figure.type == 'p'
                    p_cell = rand_figure.cell
                    fields.push("#{p_cell.name[0]}#{p_cell.name[1].to_i - 1}", "#{p_cell.name[0]}#{p_cell.name[1].to_i - 2}", "#{p_cell.name[0]}#{p_cell.name[1].to_i - 2}")
                end
                fields.size.times do
                    rand_turn = fields[rand(fields.size - 1)]
                    turn_error = game.check_turn(rand_figure.cell.name, rand_turn)
                    break unless turn_error.is_a? String
                end
            end
            from, to = rand_figure.cell.name, rand_turn
        else
            turn = game.possibles[rand(game.possibles.size - 1)]
            from, to = turn[0], turn[1]
        end
        Turn.build(game.id, from, to)
    end
end
