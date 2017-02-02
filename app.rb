require 'nokogiri'

builder = Nokogiri::XML::Builder.new(:encoding => 'UTF-8') do |xml| 
	xml.root {
    xml.products {
      xml.widget {
        xml.id_ "10"
        xml.name "Awesome widget"
      }
    }
  }
end
puts builder.to_xml
