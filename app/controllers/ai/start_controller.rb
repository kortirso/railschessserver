class Ai::StartController < ApplicationController
    def index
        if session[:guest].nil?
            render nothing: true
        else
            Game.where(guest: session[:guest]).destroy_all
            game = Game.build(nil, session[:guest])
            redirect_to game
        end
    end
end