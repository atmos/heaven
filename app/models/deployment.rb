class Deployment < ActiveRecord::Base
  validates_presence_of :name, :name_with_owner

  def self.latest_for_name_with_owner(name_with_owner)
    self.where(:name_with_owner => name_with_owner).
      group("name,environment").
      order("created_at desc")
  end

  def payload
    @payload ||= JSON.parse(custom_payload)
  end
end
