require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require '../helper'
require 'dotenv/load'

@listings = []
def listings
  # Calling for top 50 sales listings that are vowed to Elegran
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings?vow_company.name[contains]=Elegran%20Real%20Estate&sale_rental.code=S&sort_by[price]=desc&price[gt]=3000000&status[in]%5B%5D=active&auth_token=#{ENV['AUTH_TOKEN']}")
  curl.perform
  listings_json = JSON.parse(curl.body_str)['listings']
  listings_json.each do |listing|
    # call api for the specific listing
    get_building_locations listing['building']['id']
    get_promo_listing listing['id']

    @listing_hash = {
      IdWeb: listing['id'],
      AddrDisplay: "#{listing['no_of_bedrooms'].to_i}bedrooms in #{@building_json['locations'][0]['address']}",
    }

    20.times do |i|
      if listing['images'][i].nil?
        photo = 'Photo' + (i+1).to_s
        @listing_hash[photo] = ''
      elsif listing['images']
        photo = 'Photo' + (i+1).to_s
        @listing_hash[photo.to_s] = listing['images'][i]['url']
      end
    end
  end
    @listings << @listing_hash
end

listings
ap @listings