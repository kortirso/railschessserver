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

    def check_right_figure(from)
        result = self.board.cells.find_by(x_param: from[0], y_param: from[1]).figure.nil? ? "В клетке '#{from}' нет фигуры для хода" : nil
        return result unless result.nil?
        f_color = self.board.cells.find_by(x_param: from[0], y_param: from[1]).figure.color
        result = f_color == 'white' && self.white_turn || f_color == 'black' && !self.white_turn ? nil : "Нельзя ходить чужой фигурой"
    end

    private
    def board_build
        Board.build(self)
    end
end
