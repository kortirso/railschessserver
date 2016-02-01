class User < ActiveRecord::Base
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

    has_many :games
    has_many :as_opponent_games, class_name: 'Game', foreign_key: 'opponent_id'
    
    validates :username, presence: true, uniqueness: true, length: { in: 1..20 }
end
