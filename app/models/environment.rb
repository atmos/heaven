# A location for the deployment (i.e. production, staging)
class Environment < ActiveRecord::Base
  validates :name, :presence => true, :uniqueness => true

  has_many :deployments, :dependent => :delete_all
end