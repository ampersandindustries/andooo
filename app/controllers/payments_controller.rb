class PaymentsController < ApplicationController

  def edit
    @user = current_user
  end

  def update
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

    redirect_to details_attendances_path

  rescue Stripe::CardError => e
    flash[:error] = e.message
    render :edit
  end
end
