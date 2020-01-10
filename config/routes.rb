Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: "products#index"

  get "/products/:id/purchase", to: "products#cart", as: "product_cart"
  post "/products/:id/purchase", to: "products#purchase", as: "product_purchase"

  get "/purchases/:id", to: "purchases#show", as: "purchase"
end
