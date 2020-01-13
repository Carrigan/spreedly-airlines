class ProductsController < ApplicationController
    def index
        @products = Product.all
    end

    def cart
        @product = Product.find(params.require(:id))
        @env_token = env_token
    end

    def purchase
        @product = Product.find(params.require(:id))

        purchase_service = PurchaseService.new(@product, params.require(:spreedly_token))
        purchase = purchase_service.run()
        
        if purchase.present?
            flash[:notice] = "Purchase succeeded!"
            redirect_to purchase_path(purchase)
        else
            flash[:alert] = purchase_service.error_message
            @env_token = env_token
            render :cart
        end
    end 

    def env_token
        Rails.application.credentials.spreedly[:env_key]
    end
end
