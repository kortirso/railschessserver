RSpec.describe User, type: :model do
    it { should have_many :games }
    it { should have_many :as_opponent_games }
    it { should validate_presence_of :username }
    it { should validate_presence_of :email }
    it { should validate_presence_of :password }
    it { should validate_uniqueness_of :username }
    it { should validate_length_of :username }

    it 'is valid with username, email and password' do
        user = User.new(username: 'tester', email: 'example@gmail.com', password: 'password')
        expect(user).to be_valid
    end

    it 'is invalid without username' do
        user = User.new(username: nil)
        user.valid?
        expect(user.errors[:username]).to include("can't be blank")
    end

    it 'is invalid without email' do
        user = User.new(email: nil)
        user.valid?
        expect(user.errors[:email]).to include("can't be blank")
    end

    it 'is invalid without password' do
        user = User.new(password: nil)
        user.valid?
        expect(user.errors[:password]).to include("can't be blank")
    end

    it 'is invalid with a duplicate email' do
        User.create(username: 'tester1', email: 'example1@gmail.com', password: 'password')
        user = User.new(username: 'tester1', email: 'example2@gmail.com', password: 'password')
        user.valid?
        expect(user.errors[:username]).to include('has already been taken')
    end

    it 'is invalid with a duplicate email' do
        User.create(username: 'tester1', email: 'example@gmail.com', password: 'password')
        user = User.new(username: 'tester2', email: 'example@gmail.com', password: 'password')
        user.valid?
        expect(user.errors[:email]).to include('has already been taken')
    end

    context '.users_games' do
        let!(:user) { create :user }
        let!(:game_1) { create :game, user: user }
        let!(:game_2) { create :game, opponent: user }
        let!(:game_3) { create :game }

        it 'should return a list of games with current user' do
            games = user.users_games
            
            expect(games.count).to eq 2
            expect(games[0]).to eq game_2
            expect(games[1]).to eq game_1
        end
    end
end