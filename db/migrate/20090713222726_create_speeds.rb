class CreateSpeeds < ActiveRecord::Migration
  def self.up
    create_table :speeds do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :speeds
  end
end
