require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require '../helper'
require 'dotenv/load'

# database stored id, 
listing_id_arry = [] 

three_mil_listings
@listings_json.each do |listing|
  listing_id_arry << listing['id']
end
ap listing_id_arry

# call each listing by iterating database stored ids. 
def listing_xml(id)
  curl = Curl::Easy.new("https://api.datahubus.com/v1/listings/#{id}?auth_token=#{ENV['AUTH_TOKEN']}")
  curl.perform
  @listing_json = JSON.parse(curl.body_str)['listing']
end

# create builder for xml.
builder = Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
  xml.send('listings') do
    listing_id_arry.each do |id|
      listing_xml(id)
      xml.listing do
        xml.id @listing_json['id']
        xml.IdWeb @listing_json['id']
        xml.IdAccount '11270'
        xml.Address @listing_json['location']['address']
        xml.AddrDisplay "#{@listing_json['no_of_bedrooms'].to_i}bedrooms in #{@listing_json['location']['address']}"
        xml.AddrCrossStreet @listing_json['location']['cross_streets'].nil? ? '' : "#{@listing_json['location']['cross_streets'][0]},#{@listing_json['location']['cross_streets'][1]}"
        xml.AddrCity @listing_json['location']['city']
        xml.AddrState @listing_json['location']['state']
        xml.AddrZip @listing_json['location']['zip_code']
        xml.AddrCountry
        xml.UnitAptId @listing_json['apt_number'] ? @listing_json['apt_number'] : ''
        xml.Price @listing_json['price'].to_i
        if @listing_json['maintenance']
          xml.MonthlyCCMaintainence @listing_json['maintenance'].to_i
        elsif @listing_json['common_charges']
          xml.MonthlyCCMaintainence @listing_json['common_charges'].to_i
        else
          xml.MonthlyCCMaintainence
        end
        xml.Bedroom @listing_json['no_of_bedrooms']
        xml.BathsFull @listing_json['no_of_baths'].to_i
        xml.BathsPartial
        xml.LotAcreage
        xml.LotSizeDisplay
        xml.RoomsTotal @listing_json['no_of_rooms'].to_i
        xml.Stories
        xml.BuiltYear
        xml.SqFeetInterior (@listing_json['floor_space'].to_i * 0.092903).to_i
        xml.SqFeetInteriorDisplay
        if (@listing_json['floor_space'].to_i * 0.092903).to_i.zero?
          xml.SqFootAveragePrice
        else
          xml.SqFootAveragePrice (@listing_json['price'].to_i / (@listing_json['floor_space'].to_i * 0.092903).to_i).round
        end
        xml.RealEstateTaxMonthly @listing_json['re_taxes'] ? @listing_json['re_taxes'].to_i : ''
        xml.RealEstateTaxYear
        xml.BuildingName @listing_json['building']['slug']
        xml.BuildingUnitsTotal
        xml.BuildingFloorsTotal
        xml.CommentsLong pretty_summary(@listing_json['broker_summary'])
        xml.OpenHouse1Date
        xml.OpenHouse1Time
        xml.OpenHouse2Date
        xml.OpenHouse2Time
        xml.SchoolDistrictId
        xml.SchoolElementary
        xml.SchoolMiddle
        xml.SchoolHigh
        20.times do |i|
          if @listing_json['images'][i].nil?
            photo = 'Photo' + (i+1).to_s
            xml.send(photo)
          elsif @listing_json['images']
            photo = 'Photo' + (i+1).to_s
            xml.send(photo, @listing_json['images'][i]['url'])
          end
        end
        5.times do |i|
          if @listing_json['floorplan'].nil?
            floorplan = 'Floorplan' + (i+1).to_s
            xml.send(floorplan)
          else
            floorplan = 'Floorplan' + (i+1).to_s
            xml.send(floorplan, @listing_json['floor_plans'][i]['url'])
          end
        end
        xml.VirtualTour
        xml.VideoTour
        xml.AdvertiserHomePageURL 'www.elegran.com'
        xml.AdvertiserListingURL "www.listings/#{@listing_json['id']}"
        xml.AdvertiserLogo 'http://files.elegran.com/lob/elegran-logo.svg'
        xml.AdvertiserName 'Elegran Real Estate and Development'
        if @listing_json['agents'][0].nil?
          xml.Agent1Name
          xml.Agent1Email
          xml.Agent1PhonePrimary
          xml.Agent1Photo
          xml.Agent2Name
          xml.Agent2Email
          xml.Agent2PhonePrimary
          xml.Agent2Photo
        else
          xml.Agent1Name @listing_json['agents'][0]['name']
          xml.Agent1Email @listing_json['agents'][0]['email']
          xml.Agent1PhonePrimary @listing_json['agents'][0]['cell']
          xml.Agent1Photo @listing_json['agents'][0]['profile_image']['url']
          xml.Agent2Name 
          xml.Agent2Email 
          xml.Agent2PhonePrimary
          xml.Agent2Photo
        end
        xml.CodeFeatured
        xml.CodeBasement
        xml.CodeConstructionType
        xml.CodeCoolingType
        xml.CodeListingType @listing_json['sale_rental']['label'] == 'Rental' ? 'R' : 'S'
        xml.CodeAdditionalListingType 2
        xml.CodeLotFeature
        xml.CodeParking
        xml.CodePets
        xml.CodePopularFeature
        xml.CodePropertyType check_goodtype_ny_data(@listing_json['unit_type'])
        xml.CodeStyle
      end
    end
  end
end

node = builder.doc.xpath('//listings').last
Nokogiri::XML::Builder.with(node) do |xml|
  xml.listing do
    xml.james
    xml.james
    xml.james
    xml.james
    xml.james
    xml.james
  end
end

builder2 = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
  xml.send('root') do
    xml.Listing do
      xml.IdWeb 123
      xml.node3 do
        xml.send('node3_1', "another string")
      end
      xml.node4 "with attributes", :attribute => "some attribute", :attribute2 => "some attribute"
      xml.selfclosing
    end
  end
end

File.open('../practice_xml_files/elegran-listings.xml', 'w') do |file|
  the_file = builder.to_xml
  file.write(the_file)
end
