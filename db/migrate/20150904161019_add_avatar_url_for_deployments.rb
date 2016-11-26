class AddAvatarUrlForDeployments < ActiveRecord::Migration
  def change
    add_column :deployments, :sender_login, :string
    add_column :deployments, :sender_avatar_url, :string
    add_index :deployments, [:repository_id, :environment_id]
    add_index :deployments, [:name, :environment_id, :name_with_owner], name: "index_deployments_on_latest_for_name_with_owner"
    add_index :deployments, :created_at
  end
end
