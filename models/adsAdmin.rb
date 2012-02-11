$:.unshift File.dirname(__FILE__)

require 'socket'
require 'ServerClient'

class AdsAdmin < ServerClient
  private
  def request_connection(nickname,host,port )
    @socket = TCPSocket.new(host,port) 
    str =  "admin_info: #{nickname}\n"
    @socket.write(str)
  end
end