require 'nokogiri'
require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require './helper'
require 'dotenv/load'

@listings = []
def listings
  # Calling for top 50 sales listings that are vowed to Elegran
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings?vow_company.name[contains]=Elegran%20Real%20Estate&sale_rental.code=S&sort_by[price]=desc&status[in]%5B%5D=active&auth_token=#{ENV['AUTH_TOKEN']}&page=1&per=50")
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
      Descriptions: [
        { Description: listing['broker_summary'] },
        { Description: 'sdf' }
      ],
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
    listing['images'].each do |image|
      @photo_hash[:Photo] = {}
      @photo_hash[:Photo] = image['url']
    end
  # @listing_hash[:Photos] << @photo_hash
  @listings << @listing_hash
  end
  # ap listings_json
  # ap @listings
end
# Time.now.strftime("%d/%m/%Y")
data = [
  { Adverts: {
      Advert: {
        AdvertId: '123123123123123',
        CustomerType: 'Private',
        Nested: { 'total' => [99, 98], '@attributes' => {'foo' => 'bar', 'hello' => 'world'} },
        Descriptions: { 'Description' =>
          [ '@text' => 'jameshwang Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ex expedita autem, accusamus optio, iste unde quia sapiente, quibusdam vel minima, doloribus assumenda totam porro ullam odio excepturi hic in. Quos.', '@attributes' => { 'languages' => 'en' }
          ]
        },
        Photos: { Photo: ['url', 'url2', 'url3'] },
        BedRoom: 'asdf'
      }
    }
  }
]

def generate_xml(data, parent = false, opt = {})
  return if data.to_s.empty?
  return unless data.is_a?(Hash)
  unless parent
    # assume that if the hash has a single key that it should be the root
    root, data = data.length == 1 ? data.shift : ['root', data]
    builder = Nokogiri::XML::Builder.new(opt) do |xml|
      xml.send(root) {
        generate_xml(data, xml)
      }
    end
    File.open('./xml_files/Elegran_adverts.xml', 'w') do |file|
      the_file = builder.to_xml
      puts the_file
      return file.write(the_file)
    end
  end
  data.each { |label, value|
    if value.is_a?(Hash)
      attrs = value.fetch('@attributes', {})
      # also passing 'text' as a key makes nokogiri do the same thing
      text = value.fetch('@text', '') 
      parent.send(label, attrs, text) { 
        value.delete('@attributes')
        value.delete('@text')
        generate_xml(value, parent)
      }
    elsif value.is_a?(Array)
      value.each { |el|
        # lets trick the above into firing so we do not need to rewrite the checks
        el = { label => el }
        generate_xml(el, parent) 
      }
    else
      parent.send(label, value)
    end
  }
end

data.each do |hash| 
  generate_xml(hash)
end

