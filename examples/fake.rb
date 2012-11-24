# coding: utf-8

# a super simple FTP server with hard coded auth details and only two files
# available for download.
#
# Usage:
#
#   em-ftpd examples/fake.rb

require 'socket'
require 'stringio'
require 'tempfile'
require 'eventmachine'
require 'em/protocols/line_protocol'
require 'aws/s3'
require "rexml/document"
include REXML
AWS::S3
class FakeFTPDriver

  attr_accessor :username, :password
  $key = 'AKIAJ2IGHZQHCSJYT22A'                                #This is access_key_id
  $skey = 'etpwFn9XnqWrfYKwrr2++++hgmEBFMxCvuBus/Xy'           #This is secret_access_key
  $bkt = 'em-ftpd-trial/murhari'                          #This is bucket name

  FILE_ONE = "file does not exist"
  FILE_TWO = "This is the file number two.\n\n2009-03-21"
  
  

  def change_dir(path, &block)
    yield path == "/" || path == "/files"
  end

  def dir_contents(path, &block)
    case path
    when "/"      then
      yield [ dir_item("files"), file_item("one.txt", FILE_ONE.bytesize) ]
    when "/files" then
      yield [ file_item("two.txt", FILE_TWO.bytesize) ]
    else
      yield []
    end
  end
  
  

  def authenticate(user, pass, &block)
    userArray = []
   
	userArray = FakeFTPDriver.find                           #calling to find function 
    userArray.each do |p|
        if user == p.username && pass == p.password          #to checking correct username & password
	    yield true
		return
	  end
	end  
    yield false	
  end
  
  
  def self.find
     userArray = []
	 if file_usable?                                     #here calling to file usable? function
		  file = File.new('users.txt','r')                  #open users file for checking username and password
		 file.each_line do |line|
		    userArray << FakeFTPDriver.new.import_line(line.chomp)      #here taking each line from file
		 end
		file.close
	else
	   puts "file doesnot exists"
	end   
	return userArray
  end	
  
  def import_line(line)
	 line_array = line.split("\t")                       #here to split line data by tab
	 @username, @password = line_array                   #here giving data into username & password variable
	 return self
 end

 
 def self.file_usable?
	 return false unless File.exists?("users.txt")           #this function used to check file is exist or not?
	 return true
 end
 
  
  

  def bytes(path, &block)
    AWS::S3::Base.establish_connection!(:access_key_id => $key, :secret_access_key => $skey) #here propery connection done
    #length = AWS::S3::S3Object.size(path,'em-ftpd-trial/murhari/Dir1')
    yield '#{$bkt}#{path}'.size                                               #here return size of file in bytes
  end

  def get_file(path, &block)
      tmpfile = Tempfile.new("em-ftp")
      tmpfile.binmode     
       AWS::S3::Base.establish_connection!(:access_key_id => $key, :secret_access_key => $skey)  #here propery connection done
      item = AWS::S3::S3Object.find '#{$bkt}#{path}'               #here finding perticular file
      item.get.stream do |chunk|                                   
      tmpfile.write chunk                                           #here file written thro' s3object
      end           
     yield File.size(tmpfile.path)                                   #here return size of file in bytes
  end
=begin
  def put_file(path, data, &block)                                    #this is put file for upload file you can use at a time put file or put stream file
  	 
    AWS::S3::Base.establish_connection!(:access_key_id => $key, :secret_access_key => $skey)     #here propery connection done
    AWS::S3::S3Object.store(path, open(data), $bkt)
    yield File.size(data)                                                                         #here return size of file in bytes
  end
=end
 
  def put_file_streamed(path, data, &block)                   #this method is used for upload data by streaming
       
     AWS::S3::Base.establish_connection!(:access_key_id => $key, :secret_access_key => $skey)	    #here propery connection done  
     data.on_stream { |chunk|
     AWS::S3::S3Object.store(path, chunk, $bkt)
     }
    yield '#{$bkt}#{path}'.size                                        #here return size of file in bytes
 end
 
  def delete_file(path, &block)
  	AWS::S3::Base.establish_connection!(:access_key_id => $key, :secret_access_key => $skey)             #here propery connection done  
  	AWS::S3::S3Object.delete path, $bkt                                                             #here file gets deleted
    yield true
  end

  def delete_dir(path, &block)
  	AWS::S3::Base.establish_connection!(:access_key_id => $key, :secret_access_key => $skey)  #here propery connection done  
  	AWS::S3::S3Object.delete path, 'em-ftpd-trial/murhari'                                      #here directory gets deleted
    yield true
  end

  def rename(from, to, &block)
  	AWS::S3::Base.establish_connection!(:access_key_id => $key, :secret_access_key => $skey)        #here propery connection done  
  	AWS::S3::S3Object.rename from,to,'#{$bkt}#{path}'                                               #here file get rename
  	yield true
  end

  def make_dir(path, &block)
    yield false
  end

  private

  def dir_item(name)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => true, :size => 0)
  end

  def file_item(name, bytes)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => false, :size => bytes)
  end

end

# configure the server
#driver     FakeFTPDriver
#ftp = Net::FTPFXPTLS.new
#ftp.close()
#driver_args 1, 2, 3
#user      "ftp"
#group     "ftp"
#daemonise false
#name      "fakeftp"
#pid_file  "/var/run/fakeftp.pid"
