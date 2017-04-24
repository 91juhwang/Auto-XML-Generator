require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require '../helper'
require 'dotenv/load'

builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
  xml.send('listings') do
    three_mil_listings
    @listings_json.each do |listing|
      # call apis for the specific listing
      get_building_locations listing['building']['id']
      get_promo_listing listing['id']

      xml.Listing do
        xml.IdWeb listing['id']
        xml.IdAccount '11270'
        xml.Address @building_json['locations'][0]['address']
        xml.AddrDisplay "#{listing['no_of_bedrooms'].to_i}bedrooms in #{@building_json['locations'][0]['address']}"
        xml.AddrCrossStreet @building_json['cross_streets'].nil? ? '' : "#{@building_json['cross_streets'][0]},#{@building_json['cross_streets'][1]}"
        xml.AddrCity @building_json['locations'][0]['city']
        xml.AddrState @building_json['locations'][0]['state']
        xml.AddrZip @building_json['locations'][0]['zip_code']
        xml.AddrCountry
        xml.UnitAptId listing['apt_number'] ? listing['apt_number'] : ''
        xml.Price listing['price'].to_i
        if listing['maintenance']
          xml.MonthlyCCMaintainence listing['maintenance'].to_i
        elsif listing['common_charges']
          xml.MonthlyCCMaintainence listing['common_charges'].to_i
        else
          xml.MonthlyCCMaintainence
        end
        xml.Bedroom listing['no_of_bedrooms']
        xml.BathsFull listing['no_of_baths'].to_i
        xml.BathsPartial
        xml.LotAcreage
        xml.LotSizeDisplay
        xml.RoomsTotal listing['no_of_rooms'].to_i
        xml.Stories @building_json['no_of_floors'] ? @building_json['no_of_floors'] : ''
        xml.BuiltYear @building_json['year_build'] ? @building_json['year_build'] : ''
        xml.SqFeetInterior (listing['floor_space'].to_i * 0.092903).to_i
        xml.SqFeetInteriorDisplay
        if (listing['floor_space'].to_i * 0.092903).to_i.zero?
          xml.SqFootAveragePrice
        else
          xml.SqFootAveragePrice (listing['price'].to_i / (listing['floor_space'].to_i * 0.092903).to_i).round
        end
        xml.RealEstateTaxMonthly listing['re_taxes'] ? listing['re_taxes'].to_i : ''
        xml.RealEstateTaxYear
        xml.BuildingName @building_json['slug']
        xml.BuildingUnitsTotal
        xml.BuildingFloorsTotal
        xml.CommentsLong pretty_summary(listing['broker_summary'])
        xml.OpenHouse1Date
        xml.OpenHouse1Time
        xml.OpenHouse2Date
        xml.OpenHouse2Time
        xml.SchoolDistrictId
        xml.SchoolElementary
        xml.SchoolMiddle
        xml.SchoolHigh
        20.times do |i|
          if listing['images'][i].nil?
            photo = 'Photo' + (i+1).to_s
            xml.send(photo)
          elsif listing['images']
            photo = 'Photo' + (i+1).to_s
            xml.send(photo, listing['images'][i]['url'])
          end
        end
        5.times do |i|
          if listing['floor_plans'][i].nil?
            floorplan = 'Floorplan' + (i+1).to_s
            xml.send(floorplan)
          else
            floorplan = 'Floorplan' + (i+1).to_s
            xml.send(floorplan, listing['floor_plans'][i]['url'])
          end
        end
        xml.VirtualTour
        xml.VideoTour
        xml.AdvertiserHomePageURL 'www.elegran.com'
        xml.AdvertiserListingURL "www.listings/#{listing['id']}"
        xml.AdvertiserLogo 'http://files.elegran.com/lob/elegran-logo.svg'
        xml.AdvertiserName 'Elegran Real Estate and Development'
        if @promo_listing_json[0].nil?
          xml.Agent1Name
          xml.Agent1Email
          xml.Agent1PhonePrimary
          xml.Agent1Photo
          xml.Agent2Name
          xml.Agent2Email
          xml.Agent2PhonePrimary
          xml.Agent2Photo
        else
          xml.Agent1Name @promo_listing_json[0]['refs'][0]['promotable_item']['first_name'] + ' ' + @promo_listing_json[0]['refs'][0]['promotable_item']['last_name']
          xml.Agent1Email @promo_listing_json[0]['refs'][0]['promotable_item']['email']
          xml.Agent1PhonePrimary @promo_listing_json[0]['refs'][0]['promotable_item']['cell']
          xml.Agent1Photo @promo_listing_json[0]['refs'][0]['promotable_item']['url']
          xml.Agent2Name
          xml.Agent2Email
          xml.Agent2PhonePrimary
          xml.Agent2Photo
          xml.CodeFeatured
          xml.CodeBasement
          xml.CodeConstructionType
          xml.CodeCoolingType
          xml.CodeListingType listing['sale_rental']['label'] == 'Rental' ? 'R' : 'S'
          xml.CodeAdditionalListingType 2
          xml.CodeLotFeature
          xml.CodeParking
          xml.CodePets
          xml.CodePopularFeature
          xml.CodePropertyType check_goodtype_ny_data(listing['unit_type'])
          xml.CodeStyle
        end
      end
    end
  end
end

File.open('../xml_files/nytimes-data/elegran-listings.xml', 'w') do |file|
  the_file = builder.to_xml
  file.write(the_file)
end
