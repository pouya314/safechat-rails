class CreateKeys < ActiveRecord::Migration
  def change
    create_table :keys do |t|
      t.string :username
      t.text :content

      t.timestamps
    end
  end
end
