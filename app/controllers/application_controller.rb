# The top-level application controller
class ApplicationController < ActionController::Base
  protect_from_forgery :with => :null_session
end
