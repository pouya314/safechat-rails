json.array!(@keys) do |key|
  json.extract! key, :id, :username, :content
  json.url key_url(key, format: :json)
end
