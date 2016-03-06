class Ai::StartController < ApplicationController
    def index
        if session[:guest].nil?
            render nothing: true
        else
            Game.find_by(guest: session[:guest]).destroy
            game = Game.build(0, User.find_by(username: 'Коала Майк').id, false, 0, session[:guest])
            redirect_to game
        end
    end
end