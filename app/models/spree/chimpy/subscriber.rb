class Spree::Chimpy::Subscriber < ActiveRecord::Base
  self.table_name = "spree_chimpy_subscribers"

  EMAIL_REGEX = /\A([\w\.%\+\-]+)@([\w\-]+\.)+([\w]{2,})\z/i

  validates :email, presence: true
  validates_format_of :email, with: EMAIL_REGEX, allow_blank: false, if: :email_changed?

  after_create  :subscribe
  around_update :resubscribe
  after_destroy :unsubscribe

  delegate :subscribe, :resubscribe, :unsubscribe, to: :subscription

  def self.subscriber_exist?(subscriber_email)
    user = Spree::Chimpy::Subscriber.find_by(email: subscriber_email, subscribed: 'true')
    if user.present?
      false
    else
      true
    end
  end

private

  def subscription
    Spree::Chimpy::Subscription.new(self)
  end
end
