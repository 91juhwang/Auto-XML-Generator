require 'nokogiri'
require 'awesome_print'

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml| 
	xml.Adverts {
    xml.Advert {
      xml.AdvertId "324"
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
      xml.Address "Awesome widget"
      xml.PostalCode "Awesome widget"
      xml.City "Awesome widget"
      xml.State "Awesome widget"
      xml.Country "Awesome widget"
      xml.Geolocation {
      	xml.Latitude 123
      	xml.Longitude 123
      }
      xml.Contact {
      	xml.SiteAccountId "Awes"
      	xml.CorporateName "dfd"
      	xml.FirstName "df"
      	xml.LastName "d"
      	xml.MobilePhone "Awesome widget"
      	xml.email "Awesome w"
      	xml.Website "Awesome widget"
      	xml.Address "Awesome widget"
      	xml.PostalCode "Awesome widget"
      	xml.City "df"
      	xml.Country "df"
      	xml.Photo "link"
      	xml.AgentId "id"
      	xml.AgentEmail "email"
      	xml.AgentLandPhone 123
      }
      xml.Bathrooms 12
      xml.Garages 1
    }
  }
end
puts builder.to_xml 

# reading xml files
# xsd = Nokogiri::XML::Schema(File.read())  <----- Reads a schema file
# doc = Nokogiri::XML(File.read('xml_files/listglobal_xml_schema.xml')) # <-------- Reads a xml file
# ap doc