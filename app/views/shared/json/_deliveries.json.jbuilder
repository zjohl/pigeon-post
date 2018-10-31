json.deliveries deliveries do |delivery|
  json.partial! "shared/json/delivery.json", locals: {
      delivery: delivery,
      sender: delivery.sender,
      receiver: delivery.receiver
  }
end