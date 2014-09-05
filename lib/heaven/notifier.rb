require "heaven/notifier/default"
require "heaven/notifier/campfire"
require "heaven/notifier/hipchat"
require "heaven/notifier/flowdock"
require "heaven/notifier/slack"

module Heaven
  # The Notifier module
  module Notifier
    def self.for(payload)
      if slack?
        ::Heaven::Notifier::Slack.new(payload)
      elsif hipchat?
        ::Heaven::Notifier::Hipchat.new(payload)
      elsif flowdock?
        ::Heaven::Notifier::Flowdock.new(payload)
      elsif Rails.env.test?
        # noop on posting
      else
        ::Heaven::Notifier::Campfire.new(payload)
      end
    end

    def self.slack?
      !ENV["SLACK_TOKEN"].nil?
    end

    def self.hipchat?
      !ENV["HIPCHAT_TOKEN"].nil?
    end

    def self.flowdock?
      !ENV["FLOWDOCK_FLOW_API_TOKEN"].nil?
    end
  end
end
