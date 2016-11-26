class AddRepositoriesIndexes < ActiveRecord::Migration
  def change
    add_index :repositories, [:owner, :name], unique: true
  end
end
