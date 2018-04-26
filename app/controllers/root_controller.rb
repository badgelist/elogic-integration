class RootController < ApplicationController

  before_action :require_login

  def home
  end

end
