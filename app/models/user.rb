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
  accepts_nested_attributes_for :application

  scope :visitors,    -> { where(state: 'visitor') }
  scope :applicants,  -> { where(state: 'applicant') }
  scope :members,     -> { where(state: 'member') }
  scope :key_members, -> { where(state: 'key_member') }
  scope :voting_members, -> { where(state: 'voting_member') }

  scope :all_members, -> { where(state: %w(member key_member voting_member)) }

  scope :no_stripe_dues, -> {
    all_members
    .where(stripe_customer_id: nil)
  }

  scope :with_submitted_application, -> {
    applicants
    .includes(:application)
    .where(:'applications.state' => 'submitted')
    .order('applications.submitted_at DESC')
  }

  scope :with_started_application, -> {
    applicants
    .includes(:application)
    .where(:'applications.state' => 'started')
    .order('applications.submitted_at DESC')
  }

  scope :new_members, -> {
    all_members
    .where('setup_complete IS NULL or setup_complete = ?', false)
    .includes(:application)
    .order('applications.processed_at ASC')
  }

  scope :order_by_state, -> { order(<<-eos
    CASE state
    WHEN 'voting_member' THEN 1
    WHEN 'key_member'    THEN 2
    WHEN 'member'        THEN 3
    WHEN 'applicant'     THEN 4
    WHEN 'visitor'       THEN 5
    ELSE                      6
    END
    eos
    .squish)}

  state_machine :state, initial: :visitor do
    event :make_applicant do
      transition visitor: :applicant
    end

    event :make_attendee do
      transition applicant: :attendee
    end

    event :make_member do
      transition [:applicant, :voting_member, :key_member] => :member
    end

    event :make_key_member do
      transition [:member, :voting_member] => :key_member
    end

    event :make_voting_member do
      transition [:member, :key_member] => :voting_member
    end

    event :make_former_member do
      transition [:member, :voting_member, :key_member] => :former_member
    end

    after_transition on: [:make_member, :make_key_member, :make_former_member] do |user, _|
      user.update(voting_policy_agreement: false)
    end

    state :visitor
    state :applicant
    state :attendee

    state :member
    state :key_member
    state :voting_member
    state :former_member
  end

  def general_member?
    member? || key_member? || voting_member?
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

  def number_applications_needing_vote
    if self.voting_member?
      n = Application.where(state: 'submitted').count - Application.joins("JOIN votes ON votes.application_id = applications.id AND applications.state = 'submitted' AND votes.user_id = #{self.id}").count
      n==0 ? nil : n
    else
      nil
    end
  end

  private

  DEFAULT_PROVIDER = 'github'
end
