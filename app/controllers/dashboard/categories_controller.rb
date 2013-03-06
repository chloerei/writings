class Dashboard::CategoriesController < Dashboard::BaseController
  before_filter :find_category, :only => [:edit, :update, :destroy]

  def new
    @category = Category.new :user => current_user
  end

  def create
    @category = current_user.categories.new category_params

    if @category.save
      respond_to do |format|
        format.json { render :json => @category.as_json(:only => [:urlname, :name]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => @category.errors.full_messages.join }, :status => 400 }
      end
    end
  end

  def edit
  end

  def update
    if @category.update_attributes category_params
      respond_to do |format|
        format.json { render :json => @category.as_json(:only => [:urlname, :name]) }
      end
    else
      respond_to do |format|
        format.json { render :json => { :message => 'Validation Failed', :errors => @category.errors }, :status => 400 }
      end
    end
  end

  def destroy
    @category.destroy
    redirect_to root_url
  end

  private

  def find_category
    @category = current_user.categories.find_by(:urlname => params[:id])
  end

  def category_params
    params.require(:category).permit(:name, :urlname, :description)
  end
end
