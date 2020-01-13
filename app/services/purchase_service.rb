class PurchaseService
    def initialize(product, payment_method_token)
        @payment_method_token = payment_method_token
        @product = product
    end

    def run
        env = Spreedly::Environment.new(env_token, access_secret)
        
        @transaction = env.purchase_on_gateway(
            gateway_token, 
            @payment_method_token, 
            @product.price
        )

        create_purchase if @transaction.succeeded
    end

    def error_message
        "There was a problem processing your #{@transaction.payment_method.card_type} " +
        "card ending in #{@transaction.payment_method.last_four_digits}: #{@transaction.message} " +
        "Please try another method of payment."
    end

    def create_purchase
        Purchase.create(
            token: @transaction.token, 
            card_token: @transaction.payment_method.token, 
            last_four: @transaction.payment_method.last_four_digits,
            card_type: @transaction.payment_method.card_type,
            product: @product
        )
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
