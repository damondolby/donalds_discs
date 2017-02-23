class RecordController < ApplicationController
  def index
    list
    render :action => 'list'
  end
  
  def list3
    session[:interested_recs] = []
    #temp = ["15", "14"]
   # session[:interested_recs].concat(temp)
  end
  
  def list2
    render :text => session[:interested_recs].inspect
    
    #@test = [['IBM', 1],['IBM2', 2],['IBM3', 3]]
    #@test += [['IBM66', 6]]
    @test = [['Select Artist...', -1]]
    
    #@artistsTemp = Artist.artists
    
    for artist in Artist.artists
      @test += [[artist.name, artist.id]]
    end
  end
  
  def remove_record
  get_selected_records_session.delete(params[:rec]) # if not session[:interested_recs].nil?
  redirect_to :action => 'my_records'
end

def get_selected_records_session
  #returns the session "interested_recs" which contains the list of records that the user has selected on the search pages
  #returns an empty array if nil
  session[:interested_recs] = [] if session[:interested_recs].nil?
  return session[:interested_recs]
end
  
  
  def my_records
      @selectedRecords = get_selected_records_session
      @noRecordsMsg = "No records selected" if @selectedRecords.length == 0
  end
  

  def add_interesting_records

  
  if request.post? and not params[:selections].nil? 
    #put the record check boxes (selections) that were displayed on the page into a hash
    @selections = params[:selections]
    #if not @selections.nil?     

    #delete the records that weren't checked from the hash
    @selections.delete_if {|key, value| value >= "off" }

    #extract the values (which are record ID's) from @selections hash into the session array  
    get_selected_records_session.concat(@selections.values)
    #remove any duplicate record id's from the session arrayblank
    get_selected_records_session.uniq! 
  end
  redirect_to :action => 'my_records'

  end
    
  def list
    #render :text => params[:record].inspect
      #render :text => params[:selection].inspect
      #this bit stores the selected label and artist id's in session
      #so that they can be retrieved if someone changes the paginated page
      #which means these details are not submitted back in the form
      temp = params[:record]
      
      @recSes = session[:record_sel]
      
      if temp == nil
        @record = session[:record_sel]
        if @record == nil
          @record = Record.new
        end
      else
        @record = Record.new
        @record.artist_id = temp[:artist_id] if temp
        @record.label_id = temp[:label_id] if temp
        session[:record_sel] = @record
      end
    
      #condition is the variable that gets passed to the paginate statement
      #that retrieves data from the MySQL database.
  # condition also ensures that non-auction ones only are displayed and ones that are available (i.e. status_id = 1)
      #condition = ""# "price <> :price"# and status_id = :status_id"
      condition = "status_id = :status_id"
        if @record.artist_id != -1
            condition += " and artist_id = :artist"       
      end
      
      if @record.label_id != -1
        #if condition != ""
         # condition += " and "
        #end
        condition += " and label_id = :label"        
      end
      
      session[:record_conditions] = [condition, {:artist => @record.artist_id, :label => @record.label_id, :status_id => Status.available_id} ]
      
       #logger.info("This is my logging test:" + condition)                       
      @records = Record.find(:all,  
                              :conditions => session[:record_conditions],
#                              :conditions => [condition, {:artist => @record.artist_id, :label => @record.label_id, :status_id => Status.available_id} ], 
                              :order         => 'name ASC')
            
  @noRecordsMsg = "No records for this selection" if @records.length == 0 and request.post? 
  end
  
  def atoz
    
      #@links = get_links
      @letter = params[:id]
      
      if @letter.nil?
        @letter = 'A'
      end
      
#      sort_order = 'artists.name'#params[:sort]
#      
#      if params[:sort].nil?
#        sort_order = 'records.name'
#      end
      
      session[:record_conditions] = ["records.name like :letter and status_id = :status_id" , {:letter => @letter+'%', :status_id => Status.available_id} ]
     
      @records = Record.find(:all,
                             # :conditions => ["name like :letter and price <> :price and status_id = :status_id" , {:letter => @letter+'%', :price => -9999, :status_id => Status.available_id} ], 
           # :conditions => ["name like :letter" , {:letter => @letter+'%'} ], 
            #:conditions => ["records.name like :letter and status_id = :status_id" , {:letter => @letter+'%', :status_id => Status.available_id} ], 
            :conditions => session[:record_conditions],
            #:include => [:artist],
                              #:order         => ' #{sort_order} ASC')
            :order         => [' records.name ASC'])
  @noRecordsMsg = "No records for this selection" if @records.length == 0
  
end
  def _records
    
  end

  def offers
     
      @records = Record.find(:all,
                              :conditions => ["price = :price and status_id = :status_id" , {:price => -9999, :status_id => Status.available_id} ], 
                              :order         => 'name ASC')
            
  @noRecordsMsg = "No records are currently open to offers" if @records.length == 0
  
  end

  def add_offers
    flash[:notice] = 'Please email Don with any records you are interested in making an offer for.'
    redirect_to :action => 'offers'
  end
  
  def get_links
    ret = ""
    'a'.upto('z') { |n| ret += get_link(n) }
    return ret

  end

  def get_link(letter)
    return letter
    #return link_to 'click here', :action => 'atoz'
  end



  
  def details
    @record = Record.find(params[:id])
    @songs = Song.find(:all, :conditions => "record_id = '#{@record.id}'")
  end
  
  
  def list4_sort
    test = "test"
  end
  
  def _record_items
    @records = Record.find(:all,
                             # :conditions => ["name like :letter and price <> :price and status_id = :status_id" , {:letter => @letter+'%', :price => -9999, :status_id => Status.available_id} ], 
           # :conditions => ["name like :letter" , {:letter => @letter+'%'} ], 
           # :conditions => ["records.name like :letter and status_id = :status_id" , {:letter => @letter+'%', :status_id => Status.available_id} ], 
           :conditions => session[:record_conditions])
            #:include => ['artist'],
                              #:order         => ' #{sort_order} ASC')
            #:order         => [' records.name DESC'])   
    
    @records.sort! {|x,y| get_order.call(x,y) }
    
    #work out whether to reverse and store the sort order and direction in session
    if session[:records_sort] == params[:sort]      
      if session[:records_sort_dir] == "asc"
        session[:records_sort_dir] = "desc"       
        @records.reverse!
      else #resorted multiple times
        session[:records_sort_dir] = "asc"
      end
    else #new sort column
      session[:records_sort] = params[:sort]      
      session[:records_sort_dir] = "asc"
    end
  end
  
  def get_order 
    if params[:sort] == "artist.name"
      return lambda {|x,y| x.artist.name <=> y.artist.name }
    elsif params[:sort] == "name"
      return lambda {|x,y| x.name <=> y.name }
    elsif params[:sort] == "label.name"
      return lambda {|x,y| x.label.name <=> y.label.name }
    end
  end

end
