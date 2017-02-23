class Speed < ActiveRecord::Base
  has_many :records
  
  def self.speeds
    find(:all)
  end
end
