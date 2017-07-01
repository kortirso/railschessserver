class Identity < ApplicationRecord
    belongs_to :user
    
    validates :uid, :provider, :user_id, presence: true

    def self.find_for_oauth(auth)
        find_by(uid: auth.uid, provider: auth.provider)
    end
end
