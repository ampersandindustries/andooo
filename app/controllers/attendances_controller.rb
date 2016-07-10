class AttendancesController < ApplicationController
  before_action :require_approved_applicant
  before_action :check_if_attendance_changes_allowed, except: :details

  def new
    return redirect_to details_attendances_path if current_user.state == "attendee"
    return go_to_payment_or_scholarship_page if current_user.attendances.present?

    @attendance = Attendance.new
  end

  def create
    @attendance = current_user.attendances.build(event_id: Event.last.id)

    if @attendance.update(attendance_params)
      go_to_payment_or_scholarship_page
    else
      render :new
    end
  end

  def edit
    @attendance = Attendance.where(user: current_user, event_id: Event.last.id).first
  end

  def update
    @attendance = Attendance.find_or_initialize_by(user_id: current_user.id, event_id: Event.last.id)

    if @attendance.update(attendance_params)
      flash[:message] = "Details updated!"
      redirect_to details_attendances_path
    else
      render :edit
    end
  end

  def details
  end

  def scholarship_form
  end

  def confirm_scholarship
    if current_user.attendee?
      flash[:error] = "You have already confirmed your attendance, can't do it again!"
      redirect_to details_attendances_path
    elsif params[:attending].present?
      current_user.make_attendee!
      redirect_to details_attendances_path
    else
      flash[:error] = "Please check the confirmation box."
      render :scholarship_form
    end
  end

  def payment_form
    @user = current_user
  end

  def pay
    @user = current_user

    stripe_customer = Stripe::Customer.create(
      email: current_user.email,
      source: params[:token]
    )

    current_user.update_attribute(:stripe_customer_id, stripe_customer.id)

    Stripe::Charge.create(
      :amount => 325_00,
      :currency => "usd",
      :customer => stripe_customer.id,
      :description => "Ticket for AndConf"
    )

    current_user.make_attendee!

    redirect_to details_attendances_path

  rescue Stripe::CardError => e
    flash[:error] = e.message
    render :payment_form
  end

  def decline
    current_user.application.decline!
    flash[:message] = "Bummer! Thanks for letting us know you can't attend."
    redirect_to root_path
  end

  private

  def check_if_attendance_changes_allowed
    if Configurable[:attendance_changes_allowed] == false
      flash[:error] = "Sorry, you can no longer update your attendance details. Please email #{ATTEND_EMAIL} with any questions."
      redirect_to root_path
    end
  end

  def go_to_payment_or_scholarship_page
    if current_user.is_scholarship?
      redirect_to scholarship_form_attendances_path
    else
      redirect_to payment_form_attendances_path
    end
  end

  def attendance_params
    params.require(:attendance).permit(:badge_name, :gender, { dietary_restrictions: [] }, :dietary_additional_info, :twitter_handle, :sleeping_preference,
                                      :staying_sunday_night, :flying_in, :transport_to_venue, :transport_from_venue, :agree_to_coc,
                                      :attend_entire_conference, :interested_in_volunteering, :accept_trails_and_pool_risk, :pronouns, :roommate_request)
  end

  def require_approved_applicant
    unless logged_in? && current_user.application.approved?
      redirect_to :root and return
    end
  end
end
