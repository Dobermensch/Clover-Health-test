class CreateTestformat1s < ActiveRecord::Migration[6.0]
  def change
    create_table :testformat1s do |t|
      t.string :name, limit: 10
      t.boolean :valid
      t.integer :count, limit: 3
    end
  end
end
