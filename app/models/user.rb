class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :omniauthable, omniauth_providers: [:facebook, :vkontakte]

    has_many :games, dependent: :destroy
    has_many :as_opponent_games, class_name: 'Game', foreign_key: 'opponent_id', dependent: :destroy
    has_many :challenges, dependent: :destroy
    has_many :as_opponent_challenge, class_name: 'Challenge', foreign_key: 'opponent_id', dependent: :destroy
    has_many :identities, dependent: :destroy
    
    validates :username, presence: true, uniqueness: true, length: { in: 1..20 }

    scope :other_users, -> (user_id) { where.not(id: user_id).order(username: :asc) }

    def users_games
        games = Game.where('user_id = ? OR opponent_id = ?', self.id, self.id).order(id: :desc)
    end

    def self.find_for_oauth(auth)
        identity = Identity.find_for_oauth(auth)
        return identity.user if identity # если существует авторизация, то возвращает пользователя
        email = auth.info[:email]
        username = case auth.provider
            when 'facebook' then auth.extra[:raw_info][:name]
            when 'vkontakte' then auth.extra[:raw_info][:screen_name]
        end
        user = User.find_by(email: email)
        if user
            if user.username == username
                user.identities.create!(provider: auth.provider, uid: auth.uid)
            else
                return false
            end
        else
            user = User.find_by(username: username)
            if user
                return false
            else
                user = User.create!(username: username, email: email, password: Devise.friendly_token[0,20])
                user.identities.create!(provider: auth.provider, uid: auth.uid)
            end
        end
        user
    end
end
