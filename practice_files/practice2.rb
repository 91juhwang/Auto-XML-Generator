require 'nokogiri'
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

def process_array(label,array,xml)
  array.each do |hash|
    xml.send(label) do # Create an element named for the label
      hash.each do |key,value|
        if value.is_a?(Array)
          process_array(key,value,xml) # Recurse
        else
          xml.send(key,value) # Create <key>value</key> (using variables)
        end
      end
    end
  end
end

builder = Nokogiri::XML::Builder.new do |xml|
  xml.root do # Wrap everything in one element.
    process_array('category',data,xml)  # Start the recursion with a custom name.
  end
end

puts builder.to_xml

builder = Nokogiri::XML::Builder.new do |xml|
  xml.Adverts { process_array('Advert', data, xml) }
end

hash = { '@attributes' => { 'languages' => 'en' } }
value = hash.fetch('@attributes', {})
puts value.delete('@attributes')
