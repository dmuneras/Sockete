require 'socket'
require 'ServerClient'

class AdsClient < ServerClient
  private
  def request_connection(nickname,host,port )
    @socket = TCPSocket.new(host,port) 
    str =  "user_info: #{nickname}\n"
    @socket.write(str)
  end
end
