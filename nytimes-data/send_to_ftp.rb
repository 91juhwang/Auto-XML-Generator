require 'net/ftp'
require 'dotenv/load'

host = ENV['NYTIMES_FTP_DOMAIN']
username = ENV['NYTIMES_FTP_ID']
password = ENV['NYTIMES_FTP_PW']

ftp = Net::FTP.new(host, username, password)
ftp.passive = true
ftp.chdir('/')
ftp.putbinaryfile('../xml_files/nytimes-data/elegran-listings.xml', '/elegran-listings.xml')
ftp.close
