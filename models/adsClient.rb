require 'socket'
require 'serverClient'
class AdsClient < ServerClient

  def initialize( nickname,host,port)
    @online = true
    @advices = Queue.new
    @response = Queue.new
    begin
      request_connection( nickname,host,port )
      enqueue_from_server
      while @online do
        if @response.size > 0
          @response.size.times do
            puts @response.pop
          end
          read_from_console
          write_asynchronic_msg if @advices.size > 0 
        end 
      end
    rescue Exception => e
      puts "Somenthing happend: #{e}"
    end
  end

  def write_asynchronic_msg
    begin
      puts "========  Advices from server =========" 
      @advices.size.times do
        puts @advices.pop
      end
      puts "=======================================" 
    rescue => e
      puts "MODE PUSH: Error Writing asynchronic advices :  #{e}"
    end 
  end

  def enqueue_from_server
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
          if msg =~ /Advice from channel/ 
            @advices << msg
          else
            msg = "FROM SERVER >>>> #{msg}"
            @response << msg
          end
        rescue => e
          puts "Error writter Thread #{e}"
        end
      end
    end
  end
 
  private
  def request_connection(nickname,host,port )
    begin
      @socket = TCPSocket.new(host,port) 
      str =  "user_info: #{nickname}\n"
      @socket.write(str)
    rescue => e
      puts "I can't bind the socket because #{e}"
    end
  end

end
