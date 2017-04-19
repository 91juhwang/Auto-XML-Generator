require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require '../helper'
require 'dotenv/load'
listing_id_arry = ['58e5d2c594d4f42342fb0d5b', ]

curl = Curl::Easy.new("https://api.datahubus.com/v1/listings/58e5d2c594d4f42342fb0d5b?auth_token=#{ENV['AUTH_TOKEN']}")
  curl.perform
  @listings_json = JSON.parse(curl.body_str)['listings']

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml|
  xml.send('listings') do
    xml.Listing do
      xml.IdWeb 123
      xml.node3 do
        xml.node3_1 "another string"
      end
      xml.node4 "with attributes", :attribute => "some attribute", :attribute2 => "some attribute"
      xml.selfclosing
    end
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
  the_file = builder2.to_xml
  file.write(the_file)
end
