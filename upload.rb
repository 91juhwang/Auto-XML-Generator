require 'google/apis/drive_v3'
require 'googleauth'
require 'googleauth/stores/file_token_store'
require 'fileutils'

OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
APPLICATION_NAME = 'Drive API Ruby Quickstart'
CLIENT_SECRETS_PATH = 'client_secret.json'
CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
                             "drive-ruby-quickstart.yaml")
SCOPE = 'https://www.googleapis.com/auth/drive'

def authorize
  FileUtils.mkdir_p(File.dirname(CREDENTIALS_PATH))
  client_id = Google::Auth::ClientId.from_file(CLIENT_SECRETS_PATH)
  token_store = Google::Auth::Stores::FileTokenStore.new(file: CREDENTIALS_PATH)
  authorizer = Google::Auth::UserAuthorizer.new(
    client_id, SCOPE, token_store)
  user_id = 'default'
  credentials = authorizer.get_credentials(user_id)
  if credentials.nil?
    url = authorizer.get_authorization_url(
      base_url: OOB_URI)
    puts "Open the following URL in the browser and enter the " +
         "resulting code after authorization"
    puts url
    code = gets
    credentials = authorizer.get_and_store_credentials_from_code(
      user_id: user_id, code: code, base_url: OOB_URI)
  end
  credentials
end

# Initialize the API and authorize.
service = Google::Apis::DriveV3::DriveService.new
service.client_options.application_name = APPLICATION_NAME
service.authorization = authorize

# Find the current file id
file_id = ''
response = service.list_files(page_size: 10,
                              q: "name='Elegran_AdvertsImport.zip'",
                              fields: 'nextPageToken, files(id, name)')
response.files.each do |file|
  puts "Currently #{response.files.count} file(s) named 'Elegran_AdvertsImport.zip' exist"
  puts "File name is: #{file.name}, File ID is: (#{file.id})"
  file_id = file.id
end

# Delete a file in the folder
puts "Deleting the file - #{file_id} ......."
service.delete_file(file_id)
puts 'File Deleted'

# Create a file in the folder
puts 'Uploading a new file ..........'
folder_id = '0B0SrQss4KDbOQ29KSzY2V053Qjg'
file_metadata = {
  name: 'Elegran_AdvertsImport.zip',
  parents: [folder_id]
}
file = service.create_file(file_metadata,
                           fields: 'id',
                           upload_source: 'xml_files/Elegran_AdvertsImport.zip',
                           content_type: 'application/zip')

puts "File Id: #{file.id} is uploaded"
