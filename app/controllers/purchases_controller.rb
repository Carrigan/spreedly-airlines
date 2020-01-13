class PurchasesController < ApplicationController
    def index
        @purchases = Purchase.all
    end

    def show
        @purchase = Purchase.find(params[:id])
        @purchase_info = env.find_transaction(@purchase.token)
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
end
