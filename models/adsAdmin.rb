require 'socket'
require 'ServerClient'

class AdsAdmin < ServerClient
  private
  def request_connection(nickname,host,port )
    @socket = TCPSocket.new(host,port) 
    @socket.write("admin_info: #{nickname}\n")
    while true 
      answer = @socket.gets.chop
      if answer =~ /Welcome/
        puts(answer)
        break
      end
      pwd = ask("Enter password: ") {|q| q.echo = "x"}  
      @socket.write("pwd: #{pwd}\n")
    end
  end
end