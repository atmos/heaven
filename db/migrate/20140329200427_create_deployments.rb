class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.string :guid,            :required => true
      t.string :environment,     :required => true, :default => "production"
      t.string :name,            :required => true
      t.string :name_with_owner, :required => true
      t.string :output
      t.text   :payload
      t.string :ref,             :required => true
      t.string :sha,             :required => true

      t.timestamps
    end
  end
end
