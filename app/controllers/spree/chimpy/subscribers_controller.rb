class Spree::Chimpy::SubscribersController < ApplicationController
  respond_to :html, :json

  def create
    @subscriber = Spree::Chimpy::Subscriber.where(email: subscriber_params[:email]).first_or_initialize
    @subscriber.attributes = subscriber_params

    is_subscribed = Spree::Chimpy::Subscriber.subscriber_exist?(@subscriber.email)
    if @subscriber.save && is_subscribed == 404
      flash[:notice] = Spree.t(:success, scope: [:chimpy, :subscriber])
    else
      if is_subscribed == "subscribed"
        flash[:info] = "Your email address is already subscribed"
      else
        flash[:error] = Spree.t(:failure, scope: [:chimpy, :subscriber])
      end
    end
      referer = request.referer || root_url # Referer is optional in request.
      respond_with @subscriber, location: referer
  end

  private

    def subscriber_params
      params.require(:chimpy_subscriber).permit(:email,:first_name, :last_name, :subscribed)
    end
end
