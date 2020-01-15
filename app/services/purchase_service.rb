class PurchaseService
    def initialize(product, payment_method_token, process_locally, save_card)
        @process_locally = process_locally
        @payment_method_token = payment_method_token
        @product = product
        @save_card = save_card
    end

    def run
        # If payment caching was used, this could be disabled, but we are not using a model here
        # so just verify every time.
        return if !verify

        @transaction = @process_locally ? transact : deliver
        PaymentMethodCache.instance.set_cached_method(@transaction.payment_method) if @save_card

        create_purchase if @transaction.succeeded
    end

    def error_message
        source = @verify_response.present? ? @verify_response : @transaction

        "There was a problem processing your #{source.payment_method.card_type} " +
        "card ending in #{source.payment_method.last_four_digits}: #{source.message} " +
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

    def verify
        @verify_response = env.verify_on_gateway(
            gateway_token, 
            @payment_method_token, 
            retain_on_success: @save_card
        )

        @verify_response.succeeded?
    end

    def transact
        env.purchase_on_gateway(
            gateway_token, 
            @payment_method_token, 
            @product.price,
            retain_on_success: true
        )
    end

    def deliver
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
            product_id: @product.id,
            product_price: @product.price,
            card_number: "{{credit_card_number}}"
        }.to_json
    end

    def env
        @env ||= Spreedly::Environment.new(env_token, access_secret)
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
