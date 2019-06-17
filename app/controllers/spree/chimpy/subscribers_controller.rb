class Spree::Chimpy::SubscribersController < ApplicationController
  respond_to :html, :json

  def create
    @subscriber = Spree::Chimpy::Subscriber.where(email: subscriber_params[:email]).first_or_initialize

    @subscriber.first_name = subscriber_params[:first_name]
    @subscriber.last_name = subscriber_params[:last_name]
    @subscriber.email = subscriber_params[:email]
    @subscriber.subscribed = subscriber_params[:subscribed]

    is_subscribed = Spree::Chimpy::Subscriber.subscriber_exist?(@subscriber.email)
    if @subscriber.save && is_subscribed
      flash[:notice] = Spree.t(:success, scope: [:chimpy, :subscriber])
    else
      error_message = !is_subscribed ? "Your email address is already subscribed" : Spree.t(:failure, scope: [:chimpy, :subscriber])
      flash[:error] = error_message
    end
    referer = request.referer || root_url # Referer is optional in request.
    respond_with @subscriber, location: referer
  end

  private

    def subscriber_params
      params.require(:chimpy_subscriber).permit(:email,:first_name, :last_name, :subscribed)
    end
end
