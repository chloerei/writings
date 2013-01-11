class Dashboard::BaseController < ApplicationController
  before_filter :require_logined
  layout 'dashboard'
end
