class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

    has_many :games
    has_many :as_opponent_games, class_name: 'Game', foreign_key: 'opponent_id'

    has_many :challenges
    has_many :as_opponent_challenge, class_name: 'Challenge', foreign_key: 'opponent_id'
    
    validates :username, presence: true, uniqueness: true, length: { in: 1..20 }

    scope :other_users, -> (user_id) { where.not(id: user_id).where.not(username: 'Коала Майк') }

    def users_games
        games = Game.where('user_id = ? OR opponent_id = ?', self.id, self.id).order(id: :desc)
    end
end
