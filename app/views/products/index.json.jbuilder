json.array!(@products) do |product|
  json.extract! product, :id, :sku, :name, :description, :price_cents, :active, :available_on
  json.url product_url(product, format: :json)
end
