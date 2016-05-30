class User < ActiveRecord::Base
  EMAIL_PATTERN = /\A.+@.+\Z/

  attr_accessible :username, :name, :email,
    :application_attributes, :email_for_google, :dues_pledge, :is_scholarship,
    :voting_policy_agreement, :gender

  validates :state, presence: true

  validates :username, presence: true

  validates :email, uniqueness: true, format: {
    with:    EMAIL_PATTERN,
    message: 'address is invalid' }

  validates :dues_pledge, numericality: true, allow_blank: true

  validates :email_for_google,
    presence: true,
    if:       :setup_complete,
    format:   { with: EMAIL_PATTERN }

  has_one :application, dependent: :destroy

  has_many :attendances, dependent: :destroy
  has_many :authentications, dependent: :destroy
  has_many :votes,       dependent: :destroy
  has_many :comments,    dependent: :destroy

  after_create :create_application

  scope :visitors,    -> { where(state: 'visitor') }
  scope :applicants,  -> { where(state: 'applicant') }
  scope :attendees,     -> { where(state: 'attendee') }
  scope :application_reviewers, -> { where(state: 'application_reviewer') }

  scope :all_attendees, -> { where(state: %w(attendee application_reviewer)) }

  scope :with_submitted_application, -> {
    applicants
    .includes(:application)
    .where(:'applications.state' => 'submitted')
    .order('applications.submitted_at DESC')
  }

  scope :has_not_confirmed_attendance, -> {
   applicants.joins(:application).where(applications: { state: 'approved' })
  }

  scope :requested_scholarship, -> {
    with_submitted_application
    .where("applications.scholarship = ? or applications.scholarship = ?", "yes", "maybe")
  }

  scope :requested_stipend, -> {
    with_submitted_application
    .where("applications.travel_stipend = ? or applications.travel_stipend = ?", "yes", "maybe")
  }

  state_machine :state, initial: :visitor do
    event :make_applicant do
      transition visitor: :applicant
    end

    event :make_attendee do
      transition applicant: :attendee
    end

    event :make_application_reviewer do
      transition [:attendee] => :application_reviewer
    end

    state :visitor
    state :applicant
    state :attendee
    state :application_reviewer
  end

  def general_attendee?
    attendee? || application_reviewer?
  end

  def gravatar_url(size = 200)
    email = self.email
    hash = email ? Digest::MD5.hexdigest(email.downcase) : nil
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end

  def create_application
    self.application ||= Application.create(user_id: id)
  end

  def display_state
    state.gsub(/_/, ' ')
  end

  def logged_in!
    touch :last_logged_in_at
  end

  def voted_on?(application)
    !!vote_for(application)
  end

  def vote_for(application)
    Vote.where(application: application, user: self).first
  end

  private

  DEFAULT_PROVIDER = 'github'
end
