class Status < ActiveRecord::Base
  has_many :records
  
  def self.statuses
      find(:all)
  end
  
  def self.available_id
    return 1
  end
end
