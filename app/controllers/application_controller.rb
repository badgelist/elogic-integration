class ApplicationController < ActionController::Base
  include Clearance::Controller
  protect_from_forgery with: :exception

  before_action :require_login, except: [:health]
  before_action :set_variables, except: [:health]

  def health
    render plain: 'All is well.'
  end

private

  def set_variables
    if @window_title.present?
      @document_title = "#{@window_title} = #{APP_NAME}"
    elsif @full_window_title.present?
      @document_title = @full_window_title
    else
      @document_title = APP_NAME
    end
  end

end
