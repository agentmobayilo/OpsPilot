class HomeController < ApplicationController
  before_action :authenticate_user!, only: [ :settings ]

  def index; end

  def settings; end
end
