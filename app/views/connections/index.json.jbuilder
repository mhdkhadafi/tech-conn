json.array!(@connections) do |connection|
  json.extract! connection, :id, :plastname, :pfirstname, :clastname, :cfirstname, :company
  json.url connection_url(connection, format: :json)
end
