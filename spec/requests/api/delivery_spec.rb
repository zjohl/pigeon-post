require "rails_helper"

RSpec.describe "Deliveries", :type => :request do

  it "can list all deliveries" do
    sender = FactoryBot.create(:user)
    receiver = FactoryBot.create(:user)
    deliveries = FactoryBot.create_list(:delivery, 2, sender_id: sender.id, receiver_id: receiver.id)

    get "/api/deliveries"

    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)

    json_deliveries = json['deliveries']

    expect(json_deliveries[0]['id']).to eq(deliveries[0].id)
    expect(json_deliveries[1]['id']).to eq(deliveries[1].id)
  end

  it "can get a single delivery" do
    sender = FactoryBot.create(:user)
    receiver = FactoryBot.create(:user)
    delivery = FactoryBot.create(:delivery, sender_id: sender.id, receiver_id: receiver.id)

    get "/api/deliveries/#{delivery.id}"

    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)

    expect(json['id']).to eq(delivery.id)
    expect(json['origin']['latitude']).to eq(delivery.origin_latitude)
    expect(json['origin']['longitude']).to eq(delivery.origin_longitude)
  end

  it "can create a new delivery without a destination" do
    sender = FactoryBot.create(:user)
    receiver = FactoryBot.create(:user)
    drone = FactoryBot.create(:drone)

    post "/api/deliveries", params: {
      drone_id: drone.id,
      status: "requested",
      origin: {
        latitude: 2,
        longitude: 3
      },
      sender_id: sender.id,
      receiver_id: receiver.id
    }

    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:created)

    json = JSON.parse(response.body)
    expect(json['droneId']).to eq(drone.id)
  end

  it "can update a delivery with a destination" do
    sender = FactoryBot.create(:user)
    receiver = FactoryBot.create(:user)
    delivery = FactoryBot.create(:delivery, sender_id: sender.id, receiver_id: receiver.id)

    put "/api/deliveries/#{delivery.id}", params: {
      status: "accepted",
      destination: {
        latitude: 12,
        longitude: 37.2
      },
    }

    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)
    expect(json['id']).to eq(delivery.id)
    expect(json['status']).to eq("accepted")
    expect(json['destination']['latitude']).to eq(12)
    expect(json['destination']['longitude']).to eq(37.2)
  end

  it "can search deliveries by user" do
    user = FactoryBot.create(:user)
    other = FactoryBot.create(:user)

    FactoryBot.create(:delivery, sender_id: user.id, receiver_id: other.id)
    FactoryBot.create(:delivery, sender_id: other.id, receiver_id: user.id)

    get "/api/deliveries/search", params: {
      user_id: user.id
    }

    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)

    expect(json['deliveries'].length).to eq(2)
  end

  it "can search deliveries by status" do
    user = FactoryBot.create(:user)
    other = FactoryBot.create(:user)

    delivery = FactoryBot.create(:delivery, sender_id: user.id, receiver_id: other.id, status: "requested")
    FactoryBot.create(:delivery, sender_id: other.id, receiver_id: user.id, status: "completed")

    get "/api/deliveries/search", params: {
      user_id: user.id,
      status: "requested"
    }

    expect(response.content_type).to eq("application/json")
    expect(response).to have_http_status(:ok)

    json = JSON.parse(response.body)

    expect(json['deliveries'].length).to eq(1)
    expect(json['deliveries'][0]['status']).to eq("requested")
    expect(json['deliveries'][0]['droneId']).to eq(delivery.drone_id)
    expect(json['deliveries'][0]['destination']['latitude']).to eq(delivery.destination_latitude)
    expect(json['deliveries'][0]['sender']['id']).to eq(user.id)
    expect(json['deliveries'][0]['receiver']['id']).to eq(other.id)
  end
end
