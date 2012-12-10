class MainController < ApplicationController
  def index
    if logined?
      @books = current_user.books
    else
      render :guest_index
    end
  end
end
