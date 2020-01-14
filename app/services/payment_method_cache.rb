# In practice this would be a model, but since we have only one user and don't care a ton about
# persistence, we will save it in memory
class PaymentMethodCache
    include Singleton

    def initialize
        @method = nil
    end

    def get_cached_method
        @method
    end

    def set_cached_method(method)
        @method = method
    end
end
