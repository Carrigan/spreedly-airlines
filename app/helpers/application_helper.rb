module ApplicationHelper
    def spreedly_iframe_initializer(env_token, prefix, form_submit)
        tag("div", data: {
            control_type: "spreedly-iframe-initializer",
            env_token: env_token,
            prefix: prefix,
            form_submit: form_submit
        })
    end
end
