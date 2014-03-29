class CreateDeployments < ActiveRecord::Migration
  def change
    create_table :deployments do |t|
      t.text   :custom_payload
      t.string :environment,     :required => true, :default => "production"
      t.string :guid,            :required => true
      t.string :name,            :required => true
      t.string :name_with_owner, :required => true
      t.string :output
      t.string :ref,             :required => true
      t.string :sha,             :required => true

      t.timestamps
    end
  end
end
