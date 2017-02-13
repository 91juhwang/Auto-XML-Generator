def signed_in?
  !session[:access_token].nil?
end

def agent_checker(agent_info)
  if agent_info.nil?
    flash[:error] = "You must be an agent to access the listing"
    session[:access_token] = nil
    redirect '/login_page'
  end
end

def agent(agentid)
  curl = Curl::Easy.new("https://api.daily.datahubus.com/v1/agents/#{agentid}?auth_token=#{ENV['DAILY_API_KEY']}")
  curl.perform
  agent_json_data = JSON.parse(curl.body_str)
  ap agent_json_data
  agent_json = agent_json_data["agent"]
  return nil if agent_json_data['errors'] || agent_json_data['error']
  @agent = {
    id: agentid,
    name: agent_json["name"],
    title: agent_json["subtitle"],
    cell: agent_json["cell"],
    office: agent_json["office_number"],
     email: agent_json["email"],
    slug: agent_json["slug"],
    url: "elegran.com/agents/" + agent_json["slug"],
    profile_image: agent_json["profile_image"],
    profile_thumbnail: agent_json["profile_thumbnail"],
    profile_portrait_thumbnail: agent_json["profile_portrait_thumbnail"]
  }
  @agent
end

# Agent lists
def agents
  @agents = []
  curl = Curl::Easy.new("https://api.daily.datahubus.com/v1/agents?auth_token=#{ENV['DAILY_API_KEY']}&page=1&per=500")
  curl.perform
  all_agents_json = JSON.parse(curl.body_str)
    all_agents_json['agents'].each do |agent|
        agent = {
            id: agent['id'],
            name: agent['name'],
            slug: agent['slug']
        }
        @agents << agent
    end
    @agents = @agents.sort_by { |hsh| hsh[:slug] }
end
# Combining Pdfs
def combine(page_array, pdf_name)
  pdf = CombinePDF.new
  page_array.each do |page|
    pdf << CombinePDF.load(page)
  end
  pdf.save "static/pdf/#{pdf_name}"
end

def delimiter(number)
  number.to_s.reverse.gsub(%r{([0-9]{3}(?=([0-9])))}, "\\1,").reverse
end
# Get building information
def get_building(buildingid)
  curl = Curl::Easy.new("https://api.datahubus.com/v1/buildings/#{buildingid}?auth_token=#{ENV['API_KEY']}")
  curl.perform
  building_json = JSON.parse(curl.body_str)
    return building_json["building"]["locations"][0]["address"]
end
def building(buildingid)
  curl = Curl::Easy.new("https://api.datahubus.com/v1/buildings/#{buildingid}?auth_token=#{ENV['API_KEY']}")
  curl.perform
  building_json = JSON.parse(curl.body_str)["building"]
  # ap building_json 
  @building_hash = {
    cross_streets: building_json["locations"][0]["cross_streets"],
    neighborhood: building_json["neighborhood"]["name"],
    year_built: building_json["year_build"],
    building_access: building_json["building_access"]["label"],
    building_age: building_json["building_age"]["label"],
    building_type: building_json["building_type"]["label"],
    service_level: building_json["entrance_service_level"]["label"],
    ownership_type: building_json["ownership_type"]["label"],
    no_of_aparments: building_json["no_of_apparments"],
    no_of_floors: building_json["no_of_floors"]
  }
  @building_hash[:amenities] = []
  building_json["building_amenities"].each { |amenity| @building_hash[:amenities] << amenity }
    return @building_hash
end
# get promotion information
def promotion(id)
  @agents = []
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings/#{id}/promotions?auth_token=#{ENV['API_KEY']}")
  curl.perform
  promotions_json = JSON.parse(curl.body_str)["promotions"][0]["refs"]  
  promotions_json.each do |ref|
    agent = {
      name: ref["promotable_item"]["name"],
      title: ref["promotable_item"]["subtitle"],
      cell: ref["promotable_item"]["cell"],
      office: ref["promotable_item"]["office_number"],
      email: ref["promotable_item"]["email"],
      url: "elegran.com/agents/" + ref["promotable_item"]["slug"],
      profile_image: ref["promotable_item"]["profile_image"],
      profile_thumbnail: ref["promotable_item"]["profile_thumbnail"],
      profile_portrait_thumbnail: ref["promotable_item"]["profile_portrait_thumbnail"]
    }
    @agents << agent
  end
  ap @agents
  return @agents
end
def listing(id)
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings/#{id}?auth_token=#{ENV['API_KEY']}")
  curl.perform
  listing_json = JSON.parse(curl.body_str)["listing"]
  @listing_hash = {
    id: listing_json["id"],
    building_id: listing_json["building"]["id"],
    building_name: listing_json["building"]["name"],
    building_slug: listing_json["building"]["slug"],
    vow_company: listing_json["vow_company"]["name"],
    sale_price: delimiter(listing_json["sale_price"].to_i),
    rent_price: delimiter([listing_json["rent_cost"].to_i, listing_json["furnish_rent_cost"].to_i].max),
    type: listing_json["ownership_type"]["label"],
    cc: delimiter(listing_json["common_charges"].to_i),
    re_tax: delimiter(listing_json["re_taxes"].to_i),
    maintenance: delimiter(listing_json["maintenance"].to_i),
    tax_deduction: delimiter(listing_json["tax_deduction"].to_i),
    apartment_size_description: listing_json["apartment_size_description"],
    br: listing_json["no_of_bedrooms"],
    ba: listing_json["no_of_baths"],
    sqft: delimiter(listing_json["floor_space"].to_i),
    status: listing_json["status"],
    sale_rental: listing_json["sale_rental"]["label"],
    desc: listing_json["broker_summary"].gsub("\n", "<br>").gsub("\r", "<br>").strip.gsub(/<br>(<br>\s*)+/,'<br><br>'),
  # listed_at: listing_json["listed_at"].gsub("T00:00:00.000Z", "")
  }
  if listing_json["listed_at"]
    @listing_hash[:listed_at] = listing_json["listed_at"].gsub("T00:00:00.000Z", "")
  end
  if listing_json["apt_number"]
    @listing_hash[:unit] = listing_json["apt_number"].gsub("APT ","")
  end
  @listing_hash[:images] = []
  listing_json["images"].each do |image|
    @listing_hash[:images] << image["url"]
  end
  @listing_hash[:floor_plans] = []
  listing_json["floor_plans"].each do |plan|
    @listing_hash[:floor_plans] << plan["url"]
  end
  @listing_hash[:features] = []
  listing_json["apartment_features"].each { |feature| @listing_hash[:features] << feature }

  @listing_hash[:address] = get_building(listing_json["building"]["id"])
  ap @listing_hash
  return @listing_hash
end

def listings(company=ENV['COMPANY_NAME'], *arg)
  @listings = []
  #curl = Curl::Easy.new("http://api.datahubus.com/v1/listings?vow_company.name%5Bcontains%5D=#{$company}&auth_token=#{ENV['API_KEY']}&page=1&per=500")
  url = "https://api.datahubus.com/v1/listings?status[nin]=closed&building.name[contains]=#{arg[0]}&vow_company.name[contains]=#{company}&apt_number[contains]=#{arg[1]}&auth_token=146d228115b1edd06430cce5056139a0&page=1&per=50"
  # url = 'http://api.datahubus.com/v1/listings?vow_company.name%5Bcontains%5D=#{$company}&auth_token=#{ENV['API_KEY']}&page=1&per=500'
  url_encoded = URI::encode(url)
  ap url_encoded
  curl = Curl::Easy.new(url_encoded)
  curl.perform
  all_listings_json = JSON.parse(curl.body_str)
  all_listings_json['listings'].each do |listing|
      listing_hash = {
        id: listing["id"],
        building_id: listing["building"]["id"],
        building_name: listing["building"]["name"],
        building_slug: listing["building"]["slug"],
        sale_price: delimiter(listing["sale_price"].to_i),
        rent_price: delimiter([listing["rent_cost"].to_i, listing["furnish_rent_cost"].to_i].max),
        type: listing["ownership_type"]["label"],
        cc: delimiter(listing["common_charges"].to_i),
        re_tax: delimiter(listing["re_taxes"].to_i),
        maintenance: delimiter(listing["maintenance"].to_i),
        tax_deduction: delimiter(listing["tax_deduction"].to_i),
        br: listing["no_of_bedrooms"],
        ba: listing["no_of_baths"],
        sqft: delimiter(listing["floor_space"].to_i),
        status: listing["status"],
        sale_rental: listing["sale_rental"]["label"],
        desc: listing["broker_summary"].gsub("\n", "<br>").gsub("\r", "<br>").strip.gsub(/<br>(<br>\s*)+/,'<br><br>'),
      }
      
      if listing["listed_at"]
        listing_hash[:listed_at] = listing["listed_at"].gsub("T00:00:00.000Z", "")
      end
      if listing["apt_number"]
        listing_hash[:unit] = listing["apt_number"].gsub("APT ","") || ""
      end
      listing_hash[:images] = []
      listing["images"].each do |image|
        listing_hash[:images] << image["url"]
      end

      listing_hash[:address] = building(listing_hash[:building_id])
      @listings << listing_hash
  end
  return @listings
end
def page(template, orientation, id, i)
  renderer = ERB.new(File.read(template))
  ap renderer
  html = renderer.result(binding)
  pdf = PDFKit.new(html, dpi: 96, page_size: 'Letter', orientation: "#{orientation}", disable_smart_shrinking: false, print_media_type: true, no_outline: true, margin_top: '0in', margin_right: '0in', margin_bottom: '0in', margin_left: '0in')
  file_name = "static/temporary/p#{i}-#{id}.pdf"
  pdf.to_file(file_name)
  return file_name
end
def go(id)
  go = [method(:listing), method(:promotion)]
  Parallel.each(go, :in_threads => 2) do |method|
    method.call(id)
  end
end
# Creating pdf files (includes showsheet, floorplan, four-pager)
def create_pdfs(template, id)
  if template.nil?
    pages = []
    pages << page("static/templates/showsheet-front.html", "Landscape", id, 1)
    pages << page("static/templates/showsheet-back.html", "Portrait", id, 2)
    # creating a pdf file by combining pages and giving a name
    pdf_name = "#{@listing_hash[:building_slug]}-#{@listing_hash[:unit].downcase.gsub('/','-')}.pdf"
    combine(pages, pdf_name)
    send_file "static/pdf/#{pdf_name}"
  elsif template == "floorplan"
    fp = page("static/templates/floorplan.html", "Landscape", id, 1)
    send_file fp
  elsif template == "fourpager" && @listing_hash[:images].count < 8 
    flash[:error] = "Please include at least 8 images to create a 4-pager"
    redirect "/"
  elsif template =="fourpager" && @listing_hash[:floor_plans].empty?
    flash[:error] = "Please include the floorplan to create a 4-pager"
    redirect "/"  
  elsif template == "fourpager" && @listing_hash[:images].count > 7 && @listing_hash[:floor_plans] != nil
    pages = []
    pages << page("static/templates/4-pager-p1.html", "Portrait", id, 1)
    pages << page("static/templates/4-pager-p2.html", "Portrait", id, 2)
    pages << page("static/templates/4-pager-p3.html", "Portrait", id, 3)
    pages << page("static/templates/4-pager-p4.html", "Portrait", id, 4)
    pdf_name = "#{@listing_hash[:building_slug]}-#{@listing_hash[:unit].downcase.gsub('/','-')}-fourpager.pdf"
    combine(pages, pdf_name)
    send_file "static/pdf/#{pdf_name}"
  end
end

