module ApplicationHelper
    def spreedly_iframe_initializer(env_token, prefix, form_submit)
        tag("div", data: {
            control_type: "spreedly-iframe-initializer",
            env_token: env_token,
            prefix: prefix,
            form_submit: form_submit
        })
    end

    def spreedly_cached_payment_method(token, card_type, last_four) 
        tag("div", data: {
            control_type: "spreedly-payment-method",
            token: token,
            card_type: card_type,
            last_four: last_four
        })
    end
end
