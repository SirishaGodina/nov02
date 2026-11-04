class ProductsController < ApplicationController
  before_action :set_product, only: :show

  def index
    @products = Product.order(created_at: :desc)
  end

  def show
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product, notice: "Product was created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    product = Product.find(params[:id])
    product.destroy!
    redirect_to products_path, notice: "Product was deleted."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to products_path, alert: "Product could not be deleted."
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:name, :price, :stock)
  end
end
