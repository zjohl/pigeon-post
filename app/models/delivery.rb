class Delivery < ApplicationRecord
  belongs_to :sender, :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  belongs_to :drone

  enum status: [:requested, :accepted, :confirmed, :in_progress, :cancelled, :completed]

  validates :drone_id, :status, :origin_latitude, :origin_longitude, :sender_id, :receiver_id, presence: true
end