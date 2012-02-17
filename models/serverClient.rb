require 'thread'
class ServerClient 
 
   
  def initialize( nickname,host,port )
    @online = true
    @advices = Queue.new
    begin
      request_connection( nickname,host,port )
      write_from_server
      while @online do
        @online = read_from_console  
        Thread.new do
          begin
            size = @advices.size
            unless size.nil?
              puts "========  Advices from server =========" if size > 0
              @advices.size.times do
                puts @advices.pop
              end
              puts "=======================================" if size > 0
            end
          rescue => e
            p "Error #{e}"
          end
        end
      end
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
      while @online
        begin
          msg =  @socket.gets.chop unless @socket.gets.nil?
          if msg =~ /Advice from channel/ 
            @advices << msg
          else
            msg = "FROM SERVER >>>> #{msg}"
            puts msg
          end
        rescue => e
          puts "Error writter Thread #{e}"
        end
      end
    end
  end 
  
end