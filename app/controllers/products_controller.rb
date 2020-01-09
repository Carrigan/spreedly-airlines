class ProductsController < ApplicationController
    def index
        @products = Product.all
    end

    def cart
        @product = Product.find(params.require(:id))
    end

    def purchase
        binding.pry
    end 
end
