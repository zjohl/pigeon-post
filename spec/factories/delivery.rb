FactoryBot.define do
  factory :delivery do
    status { :requested }
    origin_latitude { 1 }
    origin_longitude { 2 }
    destination_latitude { 3 }
    destination_longitude { 4 }
    association :drone
    association :sender, factory: :user
    association :receiver, factory: :user
  end
end