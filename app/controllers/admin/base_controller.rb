module Admin
  class BaseController < ApplicationController
    layout "admin"

    # Add admin authentication/authorization logic here
    # before_action :authenticate_admin!
    # before_action :authorize_admin!
  end
end

