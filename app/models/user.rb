class User < ActiveRecord::Base
  attr_accessor :password
  attr_accessible :name, :password
  
  def try_to_login
    User.login(self.name, self.password)
  end
  
  def self.login(name,password)
    hashed_password = hash_password(password || "")
    find(:first, :conditions => ["name = ? and hashed_password = ?", name, hashed_password])
  end
  
  def before_create
    self.hashed_password = User.hash_password(self.password)
  end
  
  def after_create
    @password = nil
  end
  
  before_destroy :dont_distroy_user1
    
  def dont_distroy_user1
    raise "Can't destroy this user" if self.name == 'damon'
  end
  
  private
  def self.hash_password(password)
    #render_text password.inspect
    Digest::SHA1.hexdigest(password)
  end
end
