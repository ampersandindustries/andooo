class Event < ActiveRecord::Base
  has_many :attendances

  validates :name, uniqueness: true
end
