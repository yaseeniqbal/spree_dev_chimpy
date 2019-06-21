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
      list_id = Rails.application.credentials.dig(Rails.env.to_sym, :chimpy_user_list_id)
      gibbon = Gibbon::Request.new(api_key: Rails.application.credentials.dig(Rails.env.to_sym, :chimpy_key), symbolize_keys: true)
      member_id = Digest::MD5.hexdigest(subscriber_email)
    begin
      member_info = gibbon.lists(list_id).members(member_id).retrieve
      return member_info[:status]
    rescue Gibbon::MailChimpError => e
     message_body = JSON(e.raw_body)
     return  message_body["status"]
    end
  end

private

  def subscription
    Spree::Chimpy::Subscription.new(self)
  end
end
