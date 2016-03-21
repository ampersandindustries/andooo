class Attendance < ActiveRecord::Base
  attr_accessible :gender

  belongs_to :user

  validates :gender, presence: true
end
