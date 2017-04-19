def check_goodtype(unit_type)
  if unit_type == 'apartment'
    unit_type = 'Flat'
  else
    unit_type = 'House'
  end
end

def check_goodtype_ny_data(unit_type)
  if unit_type == 'apartment'
    unit_type = '10'
  else
    unit_type = '2'
  end
end

def pretty_summary(text)
  text.gsub("\n", "<br>")
      .gsub("\r", "<br>")
      .strip.gsub(/<br>(<br>\s*)+/,'<br><br>')
end

def get_building_locations(buildingid)
  curl = Curl::Easy.new("https://api.datahubus.com/v1/buildings/#{buildingid}?auth_token=#{ENV['AUTH_TOKEN']}")
  curl.perform
  @building_json = JSON.parse(curl.body_str)['building']
  # ap @building_json
end

def get_promo_listing(listingid)
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings/#{listingid}/promotions?auth_token=#{ENV['AUTH_TOKEN']}&page=1&per=50")
  curl.perform
  @promo_listing_json = JSON.parse(curl.body_str)['promotions']
  # ap @promo_listing_json
end

def three_mil_listings
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings?vow_company.name[contains]=Elegran%20Real%20Estate&sale_rental.code=S&sort_by[price]=desc&price[gt]=3000000&status[in]%5B%5D=active&auth_token=#{ENV['AUTH_TOKEN']}")
  curl.perform
  @listings_json = JSON.parse(curl.body_str)['listings']
end

# call each listing by iterating database stored ids. 
def listing_xml(id)
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings/#{id}?auth_token=#{ENV['AUTH_TOKEN']}")
  curl.perform
  @listing_json = JSON.parse(curl.body_str)['listing']
end

def generate_xml(data, parent)
  return if data.to_s.empty?
  return unless data.is_a?(Hash)

  data.each do |label, value|
    if value.is_a?(Hash)
      attrs = value.fetch('@attributes', {})
      text = value.fetch('@text', '') 
      parent.send(label, attrs, text) {
        # deleteing @attributes in case it is nested
        value.delete('@attributes')
        value.delete('@text')
        generate_xml(value, parent)
      }
    elsif value.is_a?(Array)
      value.each { |el|
        # arry element becomes the hash label
        el = { label => el }
        generate_xml(el, parent) 
      }
    else
      parent.send(label, value)
    end
  end
end
