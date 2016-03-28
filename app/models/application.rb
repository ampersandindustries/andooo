class Application < ActiveRecord::Base
  belongs_to :user

  has_many :votes, dependent: :destroy
  has_many :comments, dependent: :destroy

  MINIMUM_YES = User.voting_members.count/2
  MAXIMUM_NO = 1

  attr_protected :id

  validates :user_id, presence: true
  validates :state, presence: true
  validate :validate_agreed, if: :submitted?

  scope :for_applicant, -> {
    includes(:user)
    .where(:'users.state' => 'applicant')
  }

  scope :submitted, -> {
    for_applicant
    .where(state: 'submitted')
    .order('applications.submitted_at DESC')
  }

  scope :started,   -> {
    for_applicant
    .where(state: 'started')
    .order('applications.created_at DESC')
  }

  def yes_votes
    @_yes_votes ||= votes.select(&:yes?)
  end

  def no_votes
    @_no_votes ||= votes.select(&:no?)
  end

  def not_voted_count
    @_not_voted_count ||= begin
      User.voting_members.count - votes.size
    end
  end

  def votes_threshold_email
    if rejectable? || approvable?
      ApplicationsMailer.votes_threshold(self).deliver_now
    end
  end

  state_machine :state, initial: :started do

    after_transition started: :submitted do |application|
      ApplicationsMailer.submitted(application).deliver_now
      application.touch :submitted_at
    end

    after_transition submitted: [:approved, :rejected] do |application|
      application.touch :processed_at
    end

    after_transition submitted: :approved do |application|
      ApplicationsMailer.approved(application).deliver_now
    end

    after_transition approved: :confirmed do |application|
      application.touch :confirmed_at
      ApplicationsMailer.confirmed(application).deliver_now
      application.user.make_attendee
    end

    event :submit do
      transition started: :submitted
    end

    event :approve do
      transition submitted: :approved
    end

    event :reject do
      transition submitted: :rejected
    end

    event :confirm do
      transition approved: :confirmed
    end

    state :started
    state :submitted
    state :approved
    state :rejected
    state :confirmed
  end

  def approvable?
    enough_yes && few_nos && state == "submitted"
  end

  def rejectable?
    !few_nos
  end

  def self.to_approve
    self.all.map { |x| x if x.approvable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
  end

  def self.to_reject
    self.all.map { |x| x if x.rejectable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
  end

  def self.not_enough_info
    self.all.map { |x| x if !x.rejectable? && !x.approvable? && x.state == "submitted" }.compact.sort_by { |x| x.submitted_at }
  end

  private

  def validate_agreed
    unless agreed_to_all?
      errors.add(:base, "Please agree to all terms")
    end
  end

  def agreed_to_all?
    agreement_coc && agreement_attendance && agreement_deadline
  end

  def enough_yes
    yes_votes.count >= MINIMUM_YES
  end

  def few_nos
    no_votes.count <= MAXIMUM_NO
  end
end
