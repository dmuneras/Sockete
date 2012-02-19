require 'socket'
require 'serverClient'
require "highline/import"

class AdsSource < ServerClient
  
  def initialize( nickname,host,port)
     @online = true
     begin
       request_connection( nickname,host,port )
       write_from_server
       while @online do
         read_from_console
       end
     rescue Exception => e
       puts "Somenthing happend: #{e}"
     end
  end
  
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