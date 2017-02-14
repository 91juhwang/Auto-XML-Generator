require 'nokogiri'
require 'nokogiri'
require 'awesome_print'
require 'curb'
require 'json'
require './helper'

data = [
  { Adverts: { 
      Advert: {
        AdvertId: '123123123123123',
        CustomerType: 'Private',
        Nested: { 'total' => [99, 98], '@attributes' => {'foo' => 'bar', 'hello' => 'world'} },
        Descriptions: { 'Description' => 
          [ '@text' => 'jameshwang Lorem ipsum dolor sit amet, consectetur adipisicing elit. Ex expedita autem, accusamus optio, iste unde quia sapiente, quibusdam vel minima, doloribus assumenda totam porro ullam odio excepturi hic in. Quos.', '@attributes' => { 'languages' => 'en' }
          ]
        },
        Photos: { Photo: ['url', 'url2', 'url3'] },
        BedRoom: 'asdf'
      } 
    }
  }  
]

def generate_xml(data, parent = false, opt = {})
  return if data.to_s.empty?
  return unless data.is_a?(Hash)
  unless parent
    # assume that if the hash has a single key that it should be the root
    root, data = (data.length == 1) ? data.shift : ["root", data]
    builder = Nokogiri::XML::Builder.new(opt) do |xml|
      xml.send(root) {
        generate_xml(data, xml)
      }
    end
    File.open('./xml_files/practice3.xml', 'w') do |file|
      the_file = builder.to_xml
      puts the_file
      return file.write(the_file)
    end
  end
  data.each { |label, value|
    if value.is_a?(Hash)
      attrs = value.fetch('@attributes', {})
      # also passing 'text' as a key makes nokogiri do the same thing
      text = value.fetch('@text', '') 
      parent.send(label, attrs, text) { 
        value.delete('@attributes')
        value.delete('@text')
        generate_xml(value, parent)
      }
    elsif value.is_a?(Array)
      value.each { |el|
        # lets trick the above into firing so we do not need to rewrite the checks
        el = { label => el }
        generate_xml(el, parent) 
      }
    else
      parent.send(label, value)
    end
  }
end

data.each do |hash| 
  generate_xml(hash)
end


