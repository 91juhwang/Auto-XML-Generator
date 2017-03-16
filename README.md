# xml_generator

## Sumamry
Ruby script that automatically creates .xml file that meets the clients' specific schemas

- Using the recursive methods to iterate through multiple hashes. 
- Handling both the attribute and the text for each xml nodes.

As long as the namespaces or the hashses are properly defined, the `generate_xml()` method can flexibly handle multiple nested nodes with attributes and texts. 

## Usage

- Define the data by creating a method or hard coded hashes. 
  * In this case, it is defined as `listing()` method in the app.rb file.

- Define the root node.
  * In this case, it is defined as `xml.send('Adverts')` in the `builder` variable of app.rb file. 

- Specify the file 
  * In this case, it is saving in the xml_files directory as Elegran_adverts.xml 

## Google Drive

Interact with Google Drive API to auto upload and delete the generated xml files. 

  * Google Drive v3.
  * Authenticate by adding client_secret.json file (Download from the API credentials)
  * Find the file_id by specifying the query with the file name.

  >```ruby
  > file_id = ''
  > response = service.list_files(page_size: 10,
  >                               q: "name='Elegran_AdvertsImport.zip'",
  >                               fields: 'nextPageToken, files(id, name)')
  > esponse.files.each do |file|
  >   puts "Currently #{response.files.count} file(s) named 'Elegran_AdvertsImport.zip' exist"
  >   puts "File name is: #{file.name}, File ID is: (#{file.id})"
  >   file_id = file.id
  > end
  >```

  * `.delete_file(file_id)` to delete a specfic file
  * Upload a google drive file

  >```ruby
  > file_metadata = {
  >   name: 'Elegran_AdvertsImport.zip',
  >   parents: [folder_id]
  > }
  > file = service.create_file(file_metadata,
  >                            fields: 'id',
  >                            upload_source: 'xml_files/Elegran_AdvertsImport.zip',
  >                            content_type: 'application/zip')
  >```

## Crontab
  * [Development Notes: TIL](https://github.com/91juhwang/TIL/blob/master/Shell/Crontab.md)
  