class AddStateToDeployments < ActiveRecord::Migration
  def change
    add_column :deployments, :state, :string
  end
end
