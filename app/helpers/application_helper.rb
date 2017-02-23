# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def get_price(price)
    if price == -9999
      return "auction"
    else
      return number_to_currency(price, :unit => "&pound;")
    end
  end
end
