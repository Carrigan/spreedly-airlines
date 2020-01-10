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
        @env_token = env_token

        payment_method_token = params.require(:spreedly_token)
        
        env = Spreedly::Environment.new(@env_token, access_secret)
        transaction = env.purchase_on_gateway(gateway_token, payment_method_token, @product.price)

        if transaction.succeeded
            purchase = Purchase.create(
                token: transaction.token, 
                card_token: transaction.payment_method.token, 
                last_four: transaction.payment_method.last_four_digits,
                card_type: transaction.payment_method.card_type,
                product: @product
            )

            flash[:notice] = "Purchase succeeded!"
            redirect_to purchase_path(purchase)
        else
            flash[:alert] = 
                "There was a problem processing your #{transaction.payment_method.card_type} " +
                "card ending in #{transaction.payment_method.last_four_digits}: #{transaction.message} " +
                "Please try another method of payment."

            render :cart
        end
    end 

    def env_token
        Rails.application.credentials.spreedly[:env_key]
    end

    def access_secret
        Rails.application.credentials.spreedly[:access_secret]
    end

    def gateway_token
        Rails.application.credentials.spreedly[:gateway_token]
    end
end
