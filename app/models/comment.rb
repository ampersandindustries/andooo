class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :application

  attr_accessible :body, :application_id

  validates :user_id, :application_id, presence: true

  validates :body, presence: true, length: { maximum: 2000 }

  validate :user_is_an_application_reviewer

  def user_is_an_application_reviewer
    unless user && user.application_reviewer?
      errors.add(:user, 'is not an application reviewer')
    end
  end
end
