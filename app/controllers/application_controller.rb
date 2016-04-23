require "application_responder"

class ApplicationController < ActionController::Base
    self.responder = ApplicationResponder
    respond_to :html

    before_action :configure_permitted_parameters, if: :devise_controller?
    before_action :set_current_games
    before_action :set_user_session
    before_filter :set_locale
    protect_from_forgery with: :exception

    rescue_from ActionController::RoutingError, with: :render_not_found

    def catch_404
        raise ActionController::RoutingError.new(params[:path])
    end

    def locale
        session[:locale] = params[:name] == 'ru' ? 'ru' : 'en'
        redirect_to root_path
    end

    private
    def configure_permitted_parameters
        devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :password, :password_confirmation, :remember_me) }
        devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password, :remember_me) }
        devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :password, :password_confirmation, :current_password) }
    end

    def set_current_games
        @users_games = current_user.users_games.current.includes(:user, :opponent) if current_user
    end

    def set_user_session
        if current_user
            session[:user_id] = current_user.id
            session[:guest] = nil
        elsif session[:guest].nil?
            session[:guest] = Digest::MD5.hexdigest(Time.current.to_s)
        end
    end

    def render_not_found
        render template: 'shared/404', status: 404
    end

    def set_locale
        session[:locale] == 'ru' || session[:locale] == 'en' ? I18n.locale = session[:locale] : I18n.locale = http_accept_language.compatible_language_from(I18n.available_locales)
    end
end
