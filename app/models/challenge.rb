class Challenge < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'

    has_one :game

    validates :user_id, :color, :access, presence: true
    validates :color, inclusion: { in: %w(random white black) }

    scope :accessable, -> (user) { where('user_id = ? OR opponent_id = ? OR opponent_id IS NULL', user, user).order(id: :asc) }

    def self.build(user_id, opponent_id, access = '1', color = 'random')
        enemy = User.find_by(id: opponent_id.to_i)
        enemy_id = enemy.nil? ? nil : enemy.id
        if can_be_created?(opponent_id, enemy_id, user_id, access, color)
            challenge = create user_id: user_id, access: (access == '1' ? true : false), color: color, opponent_id: opponent_id
            challenge.send_creating_message(opponent_id, user_id)
        else
            challenge = error_compilation(opponent_id, enemy_id, user_id, access, color)
        end
        challenge
    end

    def self.del(ident, user_id)
        challenge = find_by(id: ident)
        if challenge
            error = challenge.is_player?(user_id) ? challenge.send_deleting_message : 'Error, you cant destroy challenge'
        else
            error = 'Error, challenge does not exist'
        end
        error
    end

    def is_player?(user_id)
        result = self.user_id == user_id || self.opponent_id == user_id ? true : false
    end

    def self.can_be_created?(opponent_id, enemy_id, user_id, access, color)
        result = (opponent_id.nil? || (enemy_id != user_id)) && %w(0 1).include?(access) && %w(white black random).include?(color) ? true : false
    end

    def send_creating_message(opponent_id, user_id)
        challenge_json = ChallengeSerializer.new(self).serializable_hash.to_json
        if opponent_id.nil?
            PrivatePub.publish_to "/users/challenges", challenge: challenge_json
        else
            PrivatePub.publish_to "/users/#{user_id}/challenges", challenge: challenge_json
            PrivatePub.publish_to "/users/#{opponent_id}/challenges", challenge: challenge_json
        end
    end

    def send_deleting_message
        PrivatePub.publish_to "/users/games", challenge: ChallengeSerializer.new(self).serializable_hash.to_json
        self.destroy
        return nil
    end

    def self.error_compilation(opponent_id, enemy_id, user_id, access, color)
        challenge = []
        challenge.push 'User does not exist' if opponent_id && enemy_id.nil?
        challenge.push 'You cant play against you' if opponent_id && enemy_id == user_id
        challenge.push 'Error access parameter, must be 1 or 0' unless %w(0 1).include?(access)
        challenge.push 'Error color parameter, must be white, black or random' unless %w(white black random).include?(color)
        challenge
    end
end
