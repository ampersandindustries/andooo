class Event < ActiveRecord::Base
  validates :name, uniqueness: true
end
