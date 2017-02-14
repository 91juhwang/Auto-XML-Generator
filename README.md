# xml_generator

Ruby script that automatically creates .xml file that meets the clients' specific schemas

- Using the recursive methods to iterate through multiple hashes. 

- Handling both the attribute and the text for each xml nodes.

As long as the namespaces or the hashses are properly defined, the `generate_xml()` method can flexibly handle multiple nested nodes with attributes and texts. 

# Usage

- Define the data by creating a method or hard coded hashes. 
  * In this case, it is defined as `listing()` method in the app.rb file, . 

- Define the root node.
  * In this case, it is defined as `xml.send('Adverts')` in the `builder` variable of app.rb file. 

- Specify the file 
  * In this case, it is saving in the xml_files directory as Elegran_adverts.xml 
