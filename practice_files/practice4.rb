require 'nokogiri'

# Opening an existing xml file
# Adding attributes section to the exisitng xml file
@doc = Nokogiri::XML(File.open('./xml_files/Elegran_adverts.xml'))

# Search the path
description = @doc.xpath('//Adverts/Advert/Descriptions/Description')

# Manipulate the attribute
description.map { |desc| desc['new_attribute'] = 'YAS!!' }

# Write!
File.open("./xml_files/Elegran_adverts.xml", 'w') {|f| f.puts @doc.to_xml }