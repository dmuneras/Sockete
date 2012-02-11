class ServerClient 
 
   
  def initialize( nickname,host,port )
    @online = true
    @pwd = false
    @logged = false
    begin
      request_connection( nickname,host,port )
      write_from_server
      while @online do
          @online = read_from_console  
      end
      Thread.kill(@writter) 
    rescue Exception => e
      puts "Somenthing happend: #{e}"
    end
  end

  def read_from_console
    user_entry = STDIN.gets
    if user_entry == "quit\n" 
      return false
    end
    if !(user_entry == "\n")
      @socket.write(user_entry)
    else
      puts " (-.-) nothing to send\n"
    end
    return true
  end

  def write_from_server
    @writter = Thread.new do 
      while true 
        puts @socket.gets.chop 
      end 
    end
  end 
  
end