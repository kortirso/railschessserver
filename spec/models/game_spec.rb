RSpec.describe Game, type: :model do
    it { should belong_to :user }
    it { should belong_to :opponent }
    it { should belong_to :challenge }
    it { should belong_to :ai }
    it { should have_one :board }
    it { should have_many :figures }
    it { should have_many :cells }
    it { should have_many :turns }

    it 'should be valid' do
        game = create :game

        expect(game).to be_valid
    end

    describe 'Methods' do
        let!(:user_1) { create :user }
        let!(:user_2) { create :user }

        context '.build' do
            context 'by challenge' do
                let(:challenge) { create :challenge, user: user_1, color: 'white' }

                it 'should creates new Game' do
                    expect { Game.build(challenge.id, user_2.id) }.to change(Game, :count).by(1)
                end

                it 'user_1 is owner, user_2 is opponent and game is opened' do
                    game = Game.build(challenge.id, user_2.id)

                    expect(user_1.games.first).to eq game
                    expect(user_2.as_opponent_games.first).to eq game
                    expect(game.access).to eq true
                end

                it 'and creates new Board' do
                    expect { Game.build(challenge.id, user_2.id) }.to change(Board, :count).by(1)
                end

                it 'and creates new 32 Figures' do
                    expect { Game.build(challenge.id, user_2.id) }.to change(Figure, :count).by(32)
                end
            end

            context 'by training' do
                let!(:ai) { create :ai }
                let(:guest) { Digest::MD5.hexdigest(Time.current.to_s) }

                it 'should creates new Game' do
                    expect { Game.build(nil, guest) }.to change(Game, :count).by(1)
                end

                it 'user & opponent are nils and game is closed' do
                    game = Game.build(nil, guest)

                    expect(game.user_id).to eq nil
                    expect(game.opponent_id).to eq nil
                    expect(game.access).to eq false
                end

                it 'guest and AI is not nil' do
                    game = Game.build(nil, guest)

                    expect(game.guest).to eq guest
                    expect(game.ai).to_not eq nil
                end

                it 'and creates new Board' do
                    expect { Game.build(nil, guest) }.to change(Board, :count).by(1)
                end

                it 'and creates new 32 Figures' do
                    expect { Game.build(nil, guest) }.to change(Figure, :count).by(32)
                end
            end
        end

        context '.check_users_turn' do
            let!(:game) { create :game, user: user_1, opponent: user_2 }

            context 'user_1 try to make turn' do
                it 'when whites turn, no errors' do
                    expect(game.check_users_turn(user_1.id)).to eq nil
                end

                it 'when blacks turn, get error' do
                    game.update(white_turn: false)

                    expect(game.check_users_turn(user_1.id).is_a? String).to be true
                end
            end

            context 'user_2 try to make turn' do
                it 'when whites turn, get error' do
                    expect(game.check_users_turn(user_2.id).is_a? String).to be true
                end

                it 'when blacks turn, no errors' do
                    game.update(white_turn: false)

                    expect(game.check_users_turn(user_2.id)).to eq nil
                end
            end
        end

        context '.check_cells' do
            let!(:game) { create :game, user: user_1, opponent: user_2 }

            it 'get error when empty cells' do
                from, to = '', ''

                expect(game.check_cells(from, to).is_a? String).to be true
            end

            it 'get error when similar cells' do
                from, to = 'e2', 'e2'

                expect(game.check_cells(from, to).is_a? String).to be true
            end

            it 'get error when ee2-e4' do
                from, to = 'ee2', 'e4'

                expect(game.check_cells(from, to).is_a? String).to be true
            end

            it 'no error when e2-e4' do
                from, to = 'e2', 'e4'

                expect(game.check_cells(from, to)).to eq nil
            end
        end

        context '.check_right_figure' do
            let!(:game) { create :game, user: user_1, opponent: user_2 }

            it 'get error when empty cell' do
                from = 'a3'

                expect(game.cells.find_by(name: from).figure).to eq nil
                expect(game.check_right_figure(from).is_a? String).to be true
            end

            it 'get error when touch opponent figure' do
                from = 'a7'

                expect(game.white_turn).to eq true
                expect(game.cells.find_by(name: from).figure.color).to eq 'black'
                expect(game.check_right_figure(from).is_a? String).to be true
            end

            it 'no error when touch user figure' do
                from = 'a2'

                expect(game.white_turn).to eq true
                expect(game.cells.find_by(name: from).figure.color).to eq 'white'
                expect(game.check_right_figure(from)).to eq nil
            end
        end
    end
end
