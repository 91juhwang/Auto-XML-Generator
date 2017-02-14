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

def process_array(label, array, xml)
  array.each do |hash|
    kids, attrs = hash.partition{ |k, v| v.is_a?(Array) }
    xml.send(label, Hash[attrs]) do
      kids.each{ |k, v| process_array(k, v, xml) }
    end
  end
end

builder = Nokogiri::XML::Builder.new do |xml|
  xml.Adverts { process_array('Advert', data, xml) }
end

puts builder.to_xml