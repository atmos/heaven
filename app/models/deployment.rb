class Deployment < ActiveRecord::Base
  validates_presence_of :name, :name_with_owner

  def payload
    @payload ||= JSON.parse(custom_payload)
  end
end
