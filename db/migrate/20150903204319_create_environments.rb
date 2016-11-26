class CreateEnvironments < ActiveRecord::Migration
  def up
    create_table :environments do |t|
      t.string :name, required: true, index: true, unique: true
      t.timestamps
    end

    add_column :deployments, :environment_id, :integer

    Deployment.connection.schema_cache.clear!
    Deployment.reset_column_information
    Deployment.find_each do |deployment|
      deployment.update_column(:environment_id, Environment.where(name: deployment.read_attribute(:environment)).first_or_create!.id)
    end

    change_column :deployments, :environment_id, :integer, null: false
    remove_column :deployments, :environment
  end

  def down
    add_column :deployments, :environment, :string, default: "production"

    Deployment.connection.schema_cache.clear!
    Deployment.reset_column_information
    Deployment.includes(:environment).find_each do |deployment|
      deployment.update_column(:environment, Environment.find(deployment.environment_id).first!.name)
    end

    remove_column :deployments, :environment_id

    drop_table :environments
  end
end
