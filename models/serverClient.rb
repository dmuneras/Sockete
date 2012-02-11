class ServerClient 
 
   
  def initialize( nickname,host,port )
     @online = true
     request_connection( nickname,host,port )
     @writter = write_from_server @socket
     while @online do  
       @online = read_from_console
     end
     Thread.kill(@writter) 
  end
   
  def read_from_console
    user_entry = STDIN.gets
    if user_entry == "quit\n" 
      return false
    end
    if !(user_entry == "\n")
      @socket.write(user_entry)
    else
      puts " -.- write something to send\n"
    end
    return true
  end

  def write_from_server sock
    @writter = Thread.new do 
      while true
        puts sock.gets.chop        
      end 
    end
  end 
end