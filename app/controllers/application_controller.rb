class ApplicationController < ActionController::Base
  include Clearance::Controller
  protect_from_forgery with: :exception

  before_action :require_login, except: [:health]

  def health
    render plain: 'All is well.'
  end

end
