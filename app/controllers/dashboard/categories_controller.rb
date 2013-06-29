class Dashboard::CategoriesController < Dashboard::BaseController
  before_filter :find_category, :only => [:edit, :update, :destroy]

  def new
    @category = Category.new :space => @space
  end

  def create
    @category = @space.categories.new category_params

    if @category.save
      respond_to do |format|
        format.js
        format.json { render :json => @category.as_json(:only => [:token, :name]) }
      end
    else
      respond_to do |format|
        format.js
        format.json { render :json => { :message => @category.errors.full_messages.join }, :status => 400 }
      end
    end
  end

  def edit
  end

  def update
    @category.update_attributes category_params
  end

  def destroy
    @category.destroy
  end

  private

  def find_category
    @category = @space.categories.find_by(:token => param_to_token(params[:id]))
  end

  def category_params
    params.require(:category).permit(:name)
  end
end
