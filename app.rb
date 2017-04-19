require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require './helper'
require 'dotenv/load'

@listings = []
def listings
  # Calling for top 50 sales listings that are vowed to Elegran
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings?vow_company.name[contains]=Elegran%20Real%20Estate&sale_rental.code=S&sort_by[price]=desc&status[in]%5B%5D=active&auth_token=#{ENV['AUTH_TOKEN']}&page=1&per=20")
  curl.perform
  listings_json = JSON.parse(curl.body_str)['listings']
  listings_json.each do |listing|
    # call api for the specific listing
    get_building_locations listing['building']['id']
    get_promo_listing listing['id']
    # ap listing

    @listing_hash = {
      Advert: {
        SiteAccountId: 'elegran',
        AdvertId: listing['id'][0..19],
        CustomerType: 'Private',
        AdvertType: listing['sale_rental']['label'],
        GoodType: check_goodtype(listing['unit_type']),
        PublicationDate: listing['listed_at'],
        Rooms: listing['no_of_rooms'].to_i,
        Bedrooms: listing['no_of_bedrooms'],
        LivingArea: (listing['floor_space'].to_i * 0.092903).to_i,
        Descriptions: { 'Description' =>
          [
            '@text' => pretty_summary(listing['broker_summary']), '@attributes' => { 'languages' => 'en' }
          ]
        },
        Photos: { Photo: [] },
        Price: listing['price'].to_i,
        PriceCurrency: 'USD',
        IsAuction: 0,
        Country: 'US',
        HideAddress: false, 
        Furnished: listing['furnished'],
        Address: @building_json['locations'][0]['address'],
        PostalCode: @building_json['locations'][0]['zip_code'],
        State: @building_json['locations'][0]['state'],
        City: @building_json['locations'][0]['city'],
        Geolocation: { 'Latitude' => @building_json['locations'][0]['coordinates'][0], 'Longitude' => @building_json['locations'][0]['coordinates'][1], 'Accuracy' => 8 },
        Bathrooms: listing['no_of_baths'].to_i,
        Contact: {
          SiteAccountId: 'elegran',
          CustomerType: 'Private',
          CorporateName: 'Elegran Real Estate and Development',
          Email: 'info@elegran.com',
          Address: '353 Lexington Avenue',
          PostalCode: '10016',
          City: 'New York',
          Country: 'US',
          SpokenLanguages: 'English'
        }
      }
    }
    unless @promo_listing_json[0].nil?
      @listing_hash[:Advert][:Contact][:FirstName] = @promo_listing_json[0]['refs'][0]['promotable_item']['first_name']
      @listing_hash[:Advert][:Contact][:LastName] = @promo_listing_json[0]['refs'][0]['promotable_item']['last_name']
      @listing_hash[:Advert][:Contact][:LandPhone] = @promo_listing_json[0]['refs'][0]['promotable_item']['office_number']
      @listing_hash[:Advert][:Contact][:MobilePhone] = @promo_listing_json[0]['refs'][0]['promotable_item']['cell']
      @listing_hash[:Advert][:Contact][:AgentId] = @promo_listing_json[0]['refs'][0]['promotable_item']['id']
      @listing_hash[:Advert][:Contact][:AgentEmail] = @promo_listing_json[0]['refs'][0]['promotable_item']['email']
      @listing_hash[:Advert][:Contact][:Website] = "https://www.elegran.com/agents/#{@promo_listing_json[0]['refs'][0]['promotable_item']['slug']}"
      @listing_hash[:Advert][:Contact][:Photo] = @promo_listing_json[0]['refs'][0]['promotable_item']['url']
    end

    if @building_json['year_build']
      @listing_hash[:Advert][:ConstructionYear] = @building_json['year_build']
    end

    unless listing['apt_number'].nil?
      @listing_hash[:Advert][:Reference] = @building_json['locations'][0]['address']+listing['apt_number']
    end

    if listing['sale_rental']['label'] == 'Rental'
      @listing_hash[:Advert][:PriceType] = 'Monthly'
    end
    
    if listing['maintenance']
      @listing_hash[:Advert][:ServiceCharge] = listing['maintenance'].to_i
    elsif listing['common_charges']
      @listing_hash[:Advert][:ServiceCharge] = listing['common_charges'].to_i
    end

    listing['images'].each do |img|
      @listing_hash[:Advert][:Photos][:Photo] << img['url']
    end

    @listings << @listing_hash
  end
end

listings

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
  xml.send('Adverts') do
    @listings.each do |hash|
      generate_xml(hash, xml)
    end
  end
end

File.open('./xml_files/Elegran_adverts.xml', 'w') do |file|
  the_file = builder.to_xml
  file.write(the_file)
end
