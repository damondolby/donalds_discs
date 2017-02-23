class AdminController < ApplicationController
  before_filter :authorise, :except => :login
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    #@record_pages, @records = paginate :records, :per_page => 10
    
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
      #condition will be empty if neither artist id or label id are selected
      #it will have one or other or both if they are selected.
      condition = ""
        if @record.artist_id != -1
            condition = "artist_id = :artist"       
      end
      
      if @record.label_id != -1
        if condition != ""
          condition += " and "
        end
        condition += "label_id = :label"        
      end
      
      @record_pages, @records = paginate(:records,  
                              :conditions => [condition, {:artist => @record.artist_id, :label => @record.label_id} ], 
                              :order         => 'name ASC', 
                              :per_page     => 20)
  end

  def show
    @record = Record.find(params[:record_id])
    @songs = Song.find(:all, :conditions => "record_id = '#{@record.id}'")
  end
  
  def new
    if params[:record_id] == nil
      @record = Record.new
    else
      @record = Record.find(params[:record_id])
      #render_text @record.inspect

      
    end
    #@artists = Artist.find(:all)
    #@labels = Label.find(:all)
    #@speeds = Speed.find(:all)
  end

  def create
    @record = Record.new(params[:record])
    if @record.save
      addFirstSong()
      flash[:notice] = 'Record was successfully created. Record name was added as first song.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end
  
  def addFirstSong
    @song = Song.new()
    
    #@record = Record.new(params[:record])
    @song.name = @record.name
    @song.record_id = @record.id
    @song.order = 1
    @song.save
  end
  
  def New_submit
    #render :text => params[:record_id].inspect
    if params[:record_id] == ""
      create
    else
      update      
    end
    
  end

##do check to make sure artist doesn't exist already
##todo: do something upon error
def create_artist
  @artist = Artist.new(params[:artist])
  if @artist.save
    flash[:notice] = 'Artist added successfully.'
    redirect_to :action => 'new'
  else
    render :action => 'artist_new'
  end
end

##todo: do check o make sure label doesn't exist already
##todo: do something upon error
##todo: make new label selected when returning to new new record page
def create_label
  @label = Label.new(params[:label])
  if @label.save
    flash[:notice] = 'Label added successfully.'
    redirect_to :action => 'new'
  else
    render :action => 'label_new'
  end
end
    

  def edit
    @record = Record.find(params[:record_id])
  end

  def update
    @record = Record.find(params[:record_id])
    #@attributes = params[:record]
    #@attributes[4] = 'tes'
    if @record.update_attributes(params[:record])
    #if @record.update_attributes(@attributes)
      flash[:notice] = 'Record was successfully updated.'
      redirect_to :action => 'show', :record_id => @record
    else
      render :action => 'new'#, :record_id => params[:record_id]
      #render :action => 'new', :record_id => @record
    end
  end

  def destroy
    #render_text params[:id].inspect
    Song.destroy_all("record_id = '#{params[:record_id]}'")
    Record.find(params[:record_id]).destroy    
    redirect_to :action => 'list'
  end
  
  def submitSong
    #@record = Record.find(params[:id])
    #@song = Song.new
    
    @song = Song.new(params[:song])
    @song.record_id = params[:record_id]
    if @song.save
      flash[:notice] = 'Song was successfully added.'
      redirect_to :action => 'show', :record_id => @song.record_id
    else
      render :action => 'songs'
    end
  end
  
  def songAction
    @action= params['commit']
    if @action == "Add New Song"
      addSong
    else
      editSongs
    end
   
  end
  
  def editSongs
  
    
    if Song.update(params[:song].keys, params[:song].values)
      flash[:notice] = 'Songs were updated successfully.'
      redirect_to :action => 'show', :record_id => params[:record_id]
    else
      flash[:notice] = 'There was a problem updating the songs.'
      redirect_to :action => 'songs', :record_id => params[:record_id]
    end
    

    

  end
  
  def song_delete
   Song.find(params[:songid]).destroy 
   redirect_to :action => 'songs', :record_id => params[:recordID]
    
  end
  
  def addSong
   
    @song = Song.new()
    @song.name = params[:songNew].values.last
    @song.record_id = params[:record_id]
    @song.save
    
    if @song.save
      flash[:notice] = 'New song added successfully.'
      redirect_to :action => 'songs', :record_id => params[:record_id]
    else
      flash[:notice] = 'Problem adding new song.'
      redirect_to :action => 'songs', :record_id => params[:record_id]
    end  

  end
  
  def songs
      @record = Record.find(params[:record_id])
      @songs = Song.find(:all, :conditions => "record_id = '#{@record.id}'")
  end
  
  def login
   if request.get?
     session[:user_id] = nil
     @user = User.new
   else
      @user = User.new(params[:user])
      logged_in_user = @user.try_to_login
      if logged_in_user
        session[:user_id] = logged_in_user.id
        redirect_to(:controller => "admin", :action => "list")
      else
        flash[:notice] = 'Invalid User.'
      end      
  end
  end
  
  def logout
    session[:user_id] = nil
    flash[:notice] = "Logged out"
    redirect_to :action => 'login'
  end
end
