class Challenge < ActiveRecord::Base
    belongs_to :user
    belongs_to :opponent, class_name: 'User', foreign_key: 'opponent_id'

    has_one :game

    validates :user_id, :color, :access, presence: true
    validates :color, inclusion: { in: %w(random white black) }

    scope :accessable, -> (user) { where('user_id = ? OR opponent_id = ? OR opponent_id IS NULL', user, user) }

    def self.build(user_id, opponent_id, access = true, color = 'random')
        if opponent_id || User.find_by(id: opponent_id.to_i) && %w(0 1).include?(access) && %w(white black random).include?(color)
            challenge = create user_id: user_id, access: access, color: color, opponent_id: opponent_id
            challenge_json = ChallengeSerializer.new(challenge).serializable_hash.to_json
            if opponent_id.nil?
                PrivatePub.publish_to "/users/challenges", challenge: challenge_json
            else
                PrivatePub.publish_to "/users/#{user_id}/challenges", challenge: challenge_json
                PrivatePub.publish_to "/users/#{opponent_id}/challenges", challenge: challenge_json
            end
            challenge
        else
            error = ''
            error += 'User does not exist;' if opponent_id && User.find_by(id: opponent_id.to_i)
            error += 'Error access parameter, must be 1 or 0;' unless %w(0 1).include?(access)
            error += 'Error color parameter, must be white, black or random' unless %w(white black random).include?(color)
        end
    end

    def del(current_user)
        if self.user_id == current_user || self.opponent_id == current_user
            PrivatePub.publish_to "/users/games", challenge: ChallengeSerializer.new(self).serializable_hash.to_json
            self.destroy
        end
    end
end
