class Record < ActiveRecord::Base
  belongs_to :artist
  belongs_to :label
  belongs_to :speed
  has_many :songs
  belongs_to :status
  
  validates_presence_of :name
  
  def validate
    errors.add(:year, "The year isn't valid. (Leave blank if unknown.)") unless year.nil? || (year >= 1900 and year <=2500)
    errors.add(:price, "The price isn't valid. (Should be a positive number or enter -9999 if an auction one") unless price > 0 or price == -9999
  end
  
  def year_display
    if year.nil?
      "Unknown"
    else
      year
    end
  end
  
   def isRecorded_display
    if isRecorded == 1
      "Yes"
    else
      "No"
    end
  end
  
  def hasBeenSold_display
    if hasBeenSold == 1
      "Yes"
    else
      "No"
    end
  end
  
  def next_record
    recordNext = Record.find(:first, :conditions => ["id > ?", id], :order  => 'id asc')    
    return recordNext
  end
  
  def previous_record
    recordNext = Record.find(:first, :conditions => ["id < ?", id], :order  => 'id desc')
    return recordNext
  end
  
  def is_auction?
  price == -9999
  end
end
