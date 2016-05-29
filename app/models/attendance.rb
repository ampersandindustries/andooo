class Attendance < ActiveRecord::Base
  attr_accessible :gender, :badge_name, :dietary_restrictions,
  :dietary_additional_info, :twitter_handle, :sleeping_preference,
  :staying_sunday_night, :flying_in, :agree_to_coc,
  :attend_entire_conference, :interested_in_volunteering, :transport_to_venue,
  :transport_from_venue, :accept_trails_and_pool_risk, :pronouns, :user_id, :event_id

  belongs_to :user
  belongs_to :event

  validates_uniqueness_of :event, scope: :user
  validates :event, presence: true

  validates :badge_name, presence: true
  validates :dietary_restrictions, presence: true
  validates :gender, presence: true
  validates :sleeping_preference, presence: true
  validates :staying_sunday_night, presence: true
  validates :flying_in, presence: true
  validates :agree_to_coc, presence: true
  validates :attend_entire_conference, presence: true
  validates :transport_to_venue, presence: true
  validates :transport_from_venue, presence: true
  validates :accept_trails_and_pool_risk, presence: true
  validates :pronouns, presence: true

  DIETARY_OPTIONS = ["Vegetarian", "Lactose Free", "Gluten Intolerant", "Vegan", "None"]
  SLEEPING_OPTIONS = [
    "I prefer to be in all women-identified housing",
    "I prefer to be in all men-identified housing",
    "I prefer to be in all-gender housing",
    "I have no preference",
    "Other — please email #{ATTEND_EMAIL} with accommodation needs"
  ]
  STAYING_OVER_OPTIONS = %w(Yes No Maybe)
  FLYING_IN_OPTIONS = %w(Yes No)
  TRANSPORT_TO_VENUE_OPTIONS = ["I will be taking the free shuttle leaving downtown San Francisco on FRIDAY, August 12th at 3pm",
    "I will be driving myself or organizing carpooling via the doc or #transportation slack channel"]
  TRANSPORT_FROM_VENUE_OPTIONS = ["I will be taking the free shuttle leaving St. Dorothy's Rest on SUNDAY, August 14th at 8pm, returning to downtown San Francisco",
"I will be taking the free shuttle leaving St. Dorothy's Rest on MONDAY, August 15th at 10am, returning to downtown San Francisco",
"I will be driving myself or organizing carpooling via the doc or #transportation slack channel"]

end
