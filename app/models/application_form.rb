class ApplicationForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :user, :application

  delegate :name, :email, to: :user
  delegate :agreement_coc, :agreement_attendance, :agreement_deadline,
    :why_andconf, :feminism, :programming_experience, :diversity,
    :scholarship, :travel_stipend, :attend_last_year, :referral_code, to: :application

  validates :name, :email, presence: :true
  validates :agreement_coc, :agreement_attendance, :agreement_deadline,
    :why_andconf, :feminism, :programming_experience, :scholarship,
    :travel_stipend, presence: :true, unless: :saving_as_draft
  validates_length_of :why_andconf, maximum: 1000
  validates_length_of :feminism, maximum: 1000
  validates_length_of :diversity, maximum: 1000

  validates :attend_last_year, inclusion: { in: [true, false] }, unless: :saving_as_draft

  def initialize(user)
    @user = user
    @application = user.application
  end

  def save_draft(params)
    @draft = true

    set_params(params)

    if valid?
      save
    end
  end

  def submit(params)
    @draft = false

    set_params(params)
    if valid?
      @application.submit! if save
    end
  end

  def flash_message
    if saved? && saving_as_draft
      "Application draft saved!"
    elsif saved? && !saving_as_draft
      "Application submitted!"
    end
  end

  private

  def saving_as_draft
    @draft ||= false
  end

  def saved?
    @saved ||= false
  end

  def set_params(params)
    @user.name = params[:name]
    @user.email = params[:email]

    app_params = params.except(:name, :email)
    @application.assign_attributes(app_params)
  end

  def save
    ActiveRecord::Base.transaction do
      if @user.save && @application.save
        @saved = true
      else
        [@user, @application].each do |model|
          model.errors.each do |e, m|
            errors.add(e, m)
          end
        end

        @saved = false
        raise ActiveRecord::Rollback.new
      end
    end
  end
end
