class Dashboard::BaseController < ApplicationController
  before_filter :require_logined
end
