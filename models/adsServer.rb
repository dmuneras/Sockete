require "socket"
class AdsServer
  attr_accessor :descriptors, :user_info
  def initialize( host,port )
    self.user_info = []
    self.descriptors = []
    @serverSocket = TCPServer.new( host, port )
    @serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
    printf("adsServer started on port %d\n", port)
    self.descriptors.push( @serverSocket )
  end 

  def run
    while true
      begin
        res = select( self.descriptors, nil, nil, nil)
        if res != nil then
          for sock in res[0]
            if sock == @serverSocket 
              accept_new_connection
            elsif sock.eof? 
              sock.close
              self.descriptors.delete(sock)
            else
              puts "hey"
              eval_msg(sock.gets(),sock) 
            end
          end
        end
      rescue => e
        puts "Somnething wrong happened #{e}"
      end
    end
  end 
  
  private
  def accept_new_connection
    newsock = @serverSocket.accept
    self.descriptors.push( newsock )
  end 
  
  def eval_msg(umsg,sock)
    if umsg =~ /user_info:/
      first_message(umsg,sock)
      return 
    elsif umsg =~ /get_ads:/ 
      index = self.descriptors.index(sock)
      sock.write("#{self.user_info[index-1][:nickname]} from " +
                "#{self.user_info[index-1][:channel]} => (underconstruction)sending ads...\n")
      return
    else
      sock.write("Take a look to the manual: #{umsg.chop} isn't a valid message\n")
    end 
  end
  
  def first_message(msg,sock)
    user_info = msg.split(" ")
    self.user_info.push({:nickname => user_info[1], :channel => user_info[2]})
    str = sprintf("Welcome %s\n", user_info[1])
    sock.write(str)
    puts str
  end

  def broadcast_string( str, omit_sock )
    self.descriptors.each do |clisock|
      if clisock != @serverSocket && clisock != omit_sock
        clisock.write(str)
      end
    end
    print(str)
  end 

end 