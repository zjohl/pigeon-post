module Api
  class DeliveriesController < ApplicationController

    def index
      render partial: "shared/json/deliveries.json", locals: {
          deliveries: Delivery.includes(:sender, :receiver).all,
      }
    end

    def show
      delivery = Delivery.includes(:sender, :receiver).find(params[:id])
      render partial: "shared/json/delivery.json", locals: {
          delivery: delivery,
          sender: delivery.sender,
          receiver: delivery.receiver
      }
    end

    def create
      params.permit(:drone_id, :status, :origin, :destination, :sender_id, :receiver_id)

      status = params[:status] || :pending
      delivery = Delivery.create!(drone_id: params[:drone_id],
                                  status: status,
                                  origin_latitude: params.dig(:origin, :latitude),
                                  origin_longitude: params.dig(:origin, :longitude),
                                  destination_latitude: params.dig(:destination, :latitude),
                                  destination_longitude: params.dig(:destination, :longitude),
                                  sender_id: params[:sender_id],
                                  receiver_id: params[:receiver_id])

      render partial: "shared/json/delivery.json", status: :created, locals: {
          delivery: delivery,
          sender: User.find(params[:sender_id]),
          receiver: User.find(params[:receiver_id])
      }
    end

    def update
      params.permit(:id, :drone_id, :status, :origin, :destination, :sender_id, :receiver_id)
      delivery = Delivery.find(params[:id])

      drone_id = params[:drone_id] || delivery.drone_id
      status = params[:status] || delivery.status
      origin_latitude = params.dig(:origin, :latitude) || delivery.origin_latitude
      origin_longitude = params.dig(:origin, :longitude) || delivery.origin_longitude
      destination_latitude = params.dig(:destination, :latitude) || delivery.destination_latitude
      destination_longitude = params.dig(:destination, :longitude) || delivery.destination_longitude
      sender_id = params[:sender_id] || delivery.sender_id
      receiver_id = params[:receiver_id] || delivery.receiver_id

      delivery.update!(drone_id: drone_id,
                        status: status,
                        origin_latitude: origin_latitude,
                        origin_longitude: origin_longitude,
                        destination_latitude: destination_latitude,
                        destination_longitude: destination_longitude,
                        sender_id: sender_id,
                        receiver_id: receiver_id)

      render partial: "shared/json/delivery.json", status: :ok, locals: {
          delivery: delivery,
          sender: User.find(sender_id),
          receiver: User.find(receiver_id)
      }
    end

    def index_by_user_and_status
      params.permit(:user_id, :status)
      deliveries = Delivery.includes(:sender, :receiver)
        .where("deliveries.sender_id = ? OR deliveries.receiver_id = ?",
         params[:user_id],
         params[:user_id])

      if params[:status] != nil
        deliveries = deliveries.where(status: params[:status])
      end

      render partial: "shared/json/deliveries.json", locals: {
          deliveries: deliveries
      }
    end
  end
end
