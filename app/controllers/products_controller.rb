class ProductsController < ApplicationController
    before_action :set_product, only: [:cart, :purchase]
    
    def index
        @products = Product.all
    end

    def cart
        @env_token = env_token
        @payment_method = PaymentMethodCache.instance.get_cached_method
    end

    def purchase
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

    def purchase_service
        @purchase_service ||= PurchaseService.new(
            @product, 
            params.require(:spreedly_token),
            params[:deliver].nil?,
            params[:save_card].present?
        )
    end

    def set_product
        @product = Product.find(params.require(:id))
    end

    def env_token
        Rails.application.credentials.spreedly[:env_key]
    end
end
