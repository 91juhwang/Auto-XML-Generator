require 'nokogiri'
.
data = [
  { 'name' => 'category1',
    'subCategory' => [
      { 'name' => 'subCategory1',
        'descriptions' => [
          { 'desc' => 'desc1' },
          { 'name' => 'productName2',
            'desc' => 'desc2' } ]
      }]
  },
  { Price: "Awesome widget",
    PriceCurrency: "Awesome widget" 
  },
  { 'name' => 'category1',
    'subCategory' => [
      { 'name' => 'subCategory1',
        'descriptions' => [
          { 'desc' => 'desc1' },
          { 'name' => 'productName2',
            'desc' => 'desc2' } ]
      }]
  },
  { Price: "Awesome widget",
    PriceCurrency: "Awesome widget" }    
]

def process_array(label, array, xml)
  array.each do |hash|
    # Create an element named for the label
    xml.send(label) do
      hash.each do |key, value|
        if value.is_a?(Array)
          # Recurse
          process_array(key, value, xml)
        else
          # Create <key>value</key> (using variables)
          xml.send(key, value)
        end
      end
    end
  end
end

builder = Nokogiri::XML::Builder.new do |xml|
  xml.Adverts do # Wrap everything in one element.
    process_array('Advert', @listings, xml) # Start the recursion with a custom name.
  end
end

# Creating a xml file with proper nodes and information
File.open('./xml_files/Elegran_adverts.xml', 'w+') do |file|
  the_file = builder.to_xml
  file.write(the_file)
end

# Adding attributes section to the exisitng xml file
@doc = Nokogiri::XML(File.open('./xml_files/Elegran_adverts.xml'))
description = @doc.xpath('//Adverts/Advert/Descriptions/Description')
description.map { |desc| desc['new_attribute'] = 'YAS!!' }
File.open("./xml_files/Elegran_adverts.xml", 'w') {|f| f.puts @doc.to_xml }
