class AttendancesController < ApplicationController
  before_action :require_approved_applicant

  def new
    @attendance = Attendance.new
  end

  def create
    @attendance = current_user.attendances.build
    
    if @attendance.update(attendance_params)
      redirect_to payment_form_attendances_path
    else
      render :new
    end
  end

  def details
  end

  def payment_form
    @user = current_user
  end

  def pay
    @user = current_user

    stripe_customer = Stripe::Customer.create(
      email: params[:email],
      source: params[:token]
    )

    current_user.update_attribute(:stripe_customer_id, stripe_customer.id)

    Stripe::Charge.create(
      :amount => 30000,
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

  private

  def attendance_params
    params.require(:attendance).permit(:badge_name, :gender, { dietary_restrictions: [] }, :dietary_additional_info, :twitter_handle, :sleeping_preference, 
                                      :staying_sunday_night, :flying_in, :transport_to_venue, :transport_from_venue, :agree_to_coc, 
                                      :attend_entire_conference, :interested_in_volunteering, :accept_trails_and_pool_risk)
  end

  def require_approved_applicant
    unless logged_in? && current_user.application.approved?
      redirect_to :root and return
    end
  end
end
