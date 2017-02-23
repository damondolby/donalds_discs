class Label < ActiveRecord::Base
  has_many :records
  
  validates_presence_of :name
  
  def self.labels
    find(:all, :order => 'name')
  end
  
  def self.getLabelDropDown
    @retval = [['Select Label...', -1]]  
    for label in Label.labels
      @retval += [[label.name, label.id]]
    end
    return @retval
  end
end
