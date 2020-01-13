class PurchaseService
    def initialize(product, payment_method_token, process_locally)
        @process_locally = process_locally
        @payment_method_token = payment_method_token
        @product = product
    end

    def run
        env = Spreedly::Environment.new(env_token, access_secret)
    
        @transaction = @process_locally ? transact(env) : deliver(env)

        create_purchase if @transaction.succeeded
    end

    def error_message
        "There was a problem processing your #{@transaction.payment_method.card_type} " +
        "card ending in #{@transaction.payment_method.last_four_digits}: #{@transaction.message} " +
        "Please try another method of payment."
    end

    private

    def create_purchase
        Purchase.create(
            token: @transaction.token, 
            card_token: @transaction.payment_method.token, 
            last_four: @transaction.payment_method.last_four_digits,
            card_type: @transaction.payment_method.card_type,
            product: @product
        )
    end

    def transact(env)
        env.purchase_on_gateway(
            gateway_token, 
            @payment_method_token, 
            @product.price
        )
    end

    def deliver(env)
        env.deliver_to_receiver(
            receiver_token, 
            @payment_method_token, 
            headers: deliver_headers, 
            url: deliver_url, 
            body: deliver_body
        )
    end

    def deliver_url
        "https://spreedly-echo.herokuapp.com"
    end

    def deliver_headers
        {
            "Content-Type": "application/json"
        }
    end

    def deliver_body
        {
            "product_id": @product.id,
            "product_price": @product.price,
            "card_number": "{{credit_card_number}}"
        }.to_json
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

    def receiver_token
        Rails.application.credentials.spreedly[:receiver_token]
    end
end
