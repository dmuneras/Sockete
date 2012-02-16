require 'socket'
require 'ServerClient'
require "highline/import"

class AdsSource < ServerClient
  private
  def request_connection(nickname,host,port )
    @socket = TCPSocket.new(host,port)   
    @socket.write("source_info: #{nickname}\n")
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