class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string  :owner,  :required => true, :nullable => false
      t.string  :name,   :required => true, :nullable => false
      t.boolean :active, :required => true, :default => true

      t.timestamps
    end
  end
end
