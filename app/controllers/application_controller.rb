class ApplicationController < ActionController::Base
  include Clearance::Controller
  protect_from_forgery with: :exception

  def health
    render plain: 'All is well.'
  end

end
