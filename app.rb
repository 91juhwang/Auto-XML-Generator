require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require './helper'

@listings = []
def listings
  # Calling for top 50 sales listings that are vowed to Elegran
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings?vow_company.name[contains]=Elegran%20Real%20Estate&sale_rental.code=S&sort_by[price]=desc&status[in]%5B%5D=active&auth_token=146d228115b1edd06430cce5056139a0&page=1&per=50")
  curl.perform
  listings_json = JSON.parse(curl.body_str)['listings']
  listings_json.each do |listing|
    @listing_hash = {
      AdvertId: listing["id"],
      CustomerType: 'Private',
      Reference: 'abc',
      AdvertType: listing['sale_rental']['label'],
      GoodType: listing['unit_type'],
      PublicationDate: listing['listed_at'],
      Rooms: listing['no_of_rooms'],
      Bedrooms: listing['no_of_bedrooms'],
      LivingArea: listing['floor_space'],
      Descriptions: [{
        Description: listing['broker_summary'] 
      }],
      Photos: [],
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
  @listings << @listing_hash
  end
  listings_json.each do |listing|
    listing['images'].each do |i|
      photo_hash = {}
      photo_hash[:Photo] = i['url']
      @listing_hash[:Photos] << photo_hash
    end
  end
  ap listings_json
  # ap @listings
end

def building
   curl = Curl::Easy.new("https://api.datahubus.com/v1/listings?vow_company.name[contains]=Elegran%20Real%20Estate&sale_rental.code=S&sort_by[price]=desc&status[in]%5B%5D=active&auth_token=146d228115b1edd06430cce5056139a0&page=1&per=50")
end

listings

def process_array(label, array, xml)
  array.each do |hash|
    # Create an element named for the label
    xml.send(label) do
      hash.each do |key, value|
        if value.is_a?(Array)
          # Recurse
          process_array(key, value, xml)
        else
          # Create <key>value</key> (using variables)
          xml.send(key, value)
        end
      end
    end
  end
end

builder = Nokogiri::XML::Builder.new do |xml|
  xml.Adverts do # Wrap everything in one element.
    process_array('Advert', @listings, xml) # Start the recursion with a custom name.
  end
end

# Creating a xml file with proper nodes and information
File.open('./xml_files/Elegran_adverts.xml', 'w+') do |file|
  the_file = builder.to_xml
  file.write(the_file)
end

# Adding attributes section to the exisitng xml file
@doc = Nokogiri::XML(File.open('./xml_files/Elegran_adverts.xml'))
description = @doc.xpath('//Adverts/Advert/Descriptions/Description')
description.map { |desc| desc['language'] = 'en' }
File.open("./xml_files/Elegran_adverts.xml", 'w') {|f| f.puts @doc.to_xml }
