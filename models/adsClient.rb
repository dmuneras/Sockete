require 'socket'

class AdsClient 

  def initialize( nickname,channel,host,port )
    @working = true
    request_connection( nickname,channel,host,port )
    writter = Thread.new do 
      while true
        puts @socket.gets.chop        
      end 
    end
    while @working do  
      read_from_console
    end
    Thread.kill(writter) 
  end 

  private

  def request_connection(nickname,channel,host,port )
    @socket = TCPSocket.new(host,port) 
    str =  "user_info: #{nickname} #{channel}\n"
    @socket.write(str)
  end

  def read_from_console
    user_entry = STDIN.gets
    @working = false if user_entry == "quit\n"
    if !(user_entry == "\n")
      @socket.write(user_entry)
    else
      puts " -.- write something to send ...\n"
    end
  end
end
