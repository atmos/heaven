class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string  :owner,  :required => true, :nullable => false
      t.string  :name,   :required => true, :nullable => false
      t.boolean :active, :required => true, :default => true

      t.timestamps
    end

    add_column :deployments, :repository_id, :integer

    Deployment.all.each do |deployment|
      owner, name = deployment.name_with_owner.split('/')
      repository = Repository.find_or_create_by(owner: owner, name: name)
      deployment.repository = repository
      deployment.save
    end
  end
end
