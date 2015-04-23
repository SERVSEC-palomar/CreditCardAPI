class CreateOperations < ActiveRecord::Migration
  def change
    create_table :operations do |t|
      t.string :operation
      t.text :parameters
      t.timestamps null false
    end
  end
end
