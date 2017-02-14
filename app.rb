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
     # call api for the specific listing
    get_building_locations listing['building']['id']
    get_promo_listing listing['id']

    @listing_hash = {
      Advert: {
        SiteAccountId: 'elegran',
        AdvertId: listing['id'],
        CustomerType: 'Private',
        AdvertType: listing['sale_rental']['label'],
        GoodType: listing['unit_type'],
        PublicationDate: listing['listed_at'],
        Rooms: listing['no_of_rooms'],
        Bedrooms: listing['no_of_bedrooms'],
        LivingArea: listing['floor_space'],
        Descriptions: { 'Description' =>
          [
            '@text' => pretty_summary(listing['broker_summary']), '@attributes' => { 'languages' => 'en' }
          ]
        },
        Photos: { Photo: [] },
        Price: listing['price'],
        PriceCurrency: 'USD',
        IsAuction: 0,
        Country: 'US',
        HideAddress: false, 
        Furnished: listing['furnished'],
        Address: @building_json['address'],
        PostalCode: @building_json['zip_code'],
        State: @building_json['state'],
        City: @building_json['city'],
        Geolocation: { 'Latitude' => @building_json['coordinates'][0], 'Longitude' => @building_json['coordinates'][1] },
        Bathrooms: listing['no_of_bths'],
        Nested: { 'total' => [99, 98], '@attributes' => {'foo' => 'bar', 'hello' => 'world'} },
        Contact: {
          SiteAccountId: 'elegran',
          CustomerType: 'Pricate',
          CorporateName: 'Elegran Real Estate and Development',
          FirstName: @promo_listing_json[0]['refs'][0]['promotable_item']['first_name'],
          LastName: @promo_listing_json[0]['refs'][0]['promotable_item']['last_name'],
          LandPhone: '+1'+@promo_listing_json[0]['refs'][0]['promotable_item']['office_number'],
          MobilePhone: '+1'+@promo_listing_json[0]['refs'][0]['promotable_item']['cell'],
          Email: 'info@elegran.com',
          AgentId: @promo_listing_json[0]['refs'][0]['promotable_item']['id'],
          AgentEmail: @promo_listing_json[0]['refs'][0]['promotable_item']['email'],
          Website: "https://www.elegran.com/agents/#{@promo_listing_json[0]['refs'][0]['promotable_item']['slug']}",
          Address: '353 Lexington Avenue',
          PostalCode: '10016',
          City: 'New York',
          Country: 'US',
          Photo: @promo_listing_json[0]['refs'][0]['promotable_item']['profile_thumbnail']['url'],
          SpokenLanguages: 'English'
        }
      }
    }
    if @building_json['year_build']
      @listing_hash[:Advert][:ConstructionYear] = @building_json['year_build']
    end

    unless listing['apt_number'].nil?
      @listing_hash[:Advert][:Reference] = @building_json['address']+listing['apt_number']
    end

    if listing['sale_rental']['label'] == 'Rental'
      @listing_hash[:Advert][:PriceType] = 'Monthly'
    end
    
    if listing['maintenance'].nil?
      @listing_hash[:Advert][:ServiceCharge] = 0
    else
      @listing_hash[:Advert][:ServiceCharge] = listing['maintenance']
    end

    listing['images'].each do |img|
      @listing_hash[:Advert][:Photos][:Photo] << img['url']+"?#{Time.now.strftime("%d/%m/%Y")}"
    end

    @listings << @listing_hash
  end
end

listings

builder = Nokogiri::XML::Builder.new do |xml|
  xml.send('Adverts') do
    @listings.each do |hash|
      generate_xml(hash, xml)
    end
  end
end

File.open('./xml_files/Elegran_adverts.xml', 'w') do |file|
  the_file = builder.to_xml
  # puts the_file
  file.write(the_file)
end
