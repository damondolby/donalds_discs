class Artist < ActiveRecord::Base
  has_many :records
  
  validates_presence_of :name
  
  ##This is the live version
  def self.artists
    find(:all, :order => 'name')
  end
  
  def self.artists2
    @obj = ["id"=>1,"name"=>"name"]
    return @obj
  end
  
  def self.getArtistsDropDown
    @retval = [['Select Artist...', -1]]  
    for artist in Artist.artists
      @retval += [[artist.name, artist.id]]
    end
    return @retval
  end
end
