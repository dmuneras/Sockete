require 'thread'
class ServerClient 

  def read_from_console
    flag = true
    while flag
      user_entry = STDIN.gets
      if user_entry == "quit\n" 
        @online =  false
        break
      end
      if !(user_entry == "\n")
        @socket.write(user_entry)
        flag = false
      else
        puts "(-.-) Nothing to send"
      end
    end
  end

  def write_from_server
    @writter = Thread.new do 
      while @online
        begin
          if @socket.eof?
            @socket.close
            puts "Server is down"
            @online = false
            break
          end
          msg =  @socket.gets.chop
          msg = "FROM SERVER >>>> #{msg}"
          puts msg
        rescue => e
          puts "Error writter Thread #{e}"
        end
      end
    end
  end
end