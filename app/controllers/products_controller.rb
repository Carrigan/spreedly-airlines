class ProductsController < ApplicationController
    def index
        @products = Product.all
    end

    def cart
        @product = Product.find(params.require(:id))
        @env_token = Rails.application.credentials.spreedly[:env_key]
    end

    def purchase
    end 
end
