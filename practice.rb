require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require './helper'

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml| 
  xml.Adverts { 
    xml.Advert {
      xml.Contact {
        xml.SiteAccountId "Awes"
        xml.CustomerType 'Professional'
        xml.CorporateName "dfd"
        xml.FirstName "df"
        xml.LastName "d"
        xml.LandPhone 'df'
        xml.MobilePhone "Awesome widget"
        xml.email "Awesome w"
        xml.AgentLandPhone 123
        xml.AgentId "id"
        xml.AgentEmail "email"
        xml.Website "Awesome widget"
        xml.Address "Awesome widget"
        xml.PostalCode "Awesome widget"
        xml.City "df"
        xml.Country "df"
        xml.Photo "link"
        xml.SpokenLanguages "en"
      }
      xml.SiteAccountId 'elegran'
      xml.AdvertId 'df'
      xml.Reference 'saf'
      xml.CustomerType "10"
      xml.AdvertType "Awesome widget"
      xml.GoodType "Awesome widget"
      xml.PublicationDate "Awesome widget"
      xml.Rooms "Awesome widget"
      xml.Bedrooms "Awesome widget"
      xml.LivingArea "Awesome widget"
      xml.Descriptions {
        xml.Description("descriptions here", language: "en")
      } 
      xml.Photos {
        xml.Photo "link"
      }
      xml.Price "Awesome widget"
      xml.PriceCurrency "Awesome widget"
      xml.PriceType ''
      xml.IsAuction 0
      xml.Address "Awesome widget"
      xml.PostalCode "Awesome widget"
      xml.City "New York"
      xml.State "NY"
      xml.Country "US"
      xml.Geolocation {
        xml.Latitude 123
        xml.Longitude 123
      }
      xml.Furnished true
      xml.Lifts 'building acces'
      xml.ConstructionYear 'year built'
      xml.Bathrooms 12
    }
  }
end

the_file = builder.to_xml
# open a file instance with path '/path/to/file.xml' in write mode (-> 'w')
File.open('./xml_files/practice.xml', 'w+') do |file|
  # write the xml string generated above to the file
  file.write(the_file)
end