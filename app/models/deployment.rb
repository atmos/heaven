# A record of a deployment processes
class Deployment < ActiveRecord::Base
  validates :name, :name_with_owner, :environment, :repository,
    :presence => true

  belongs_to :environment
  belongs_to :repository

  def self.latest_for_name_with_owner(name_with_owner)
    sets = self.select(:name, :environment_id)
      .where(:name_with_owner => name_with_owner)
      .group([:name, :environment_id])

    sets.map do |deployment|
      params = {
        :name            => deployment.name,
        :environment_id  => deployment.environment_id,
        :name_with_owner => name_with_owner
      }
      Deployment.where(params).order(arel_table[:created_at].desc).limit(1)
    end.flatten
  end

  def payload
    @payload ||= JSON.parse(custom_payload)
  end

  def auto_deploy_payload(actor, sha)
    payload.merge(:actor => actor, :sha => sha)
  end
end
