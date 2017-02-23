module RecordHelper
  def is_in_session? (rec_id)
    #rec_id = args
    if not session[:interested_recs].nil?
      if session[:interested_recs].include?(rec_id.to_s)
        return "checked"  
      end
    end
  end 

  def get_record(id)
    Record.find(id)
  end
  
  
  def is_available_to_buy? (rec)
       rec.is_auction? or is_in_session?(rec.id)
  end
end
