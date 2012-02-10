require "socket"
class AdsServer
  
  def initialize( host,port )
    @user_info = Array::new
    @descriptors = Array::new
    @serverSocket = TCPServer.new( host, port )
    @serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
    printf("adsServer started on port %d\n", port)
    @descriptors.push( @serverSocket )
  end 

  def run
    while 1
      res = select( @descriptors, nil, nil, nil)
      if res != nil then
        for sock in res[0]
          if sock == @serverSocket 
            accept_new_connection
          elsif sock.eof? 
            str = sprintf("Client left %s:%s\n",
            sock.peeraddr[2], sock.peeraddr[1])
            broadcast_string( str, sock )
            sock.close
            @descriptors.delete(sock)
          else
            eval_msg(sock.gets(),sock) 
          end
        end
      end
    end
  end 
  
  private
  
  def accept_new_connection
    newsock = @serverSocket.accept
    @descriptors.push( newsock )
    #str = sprintf("Client joined %s:%s\n",
    #newsock.peeraddr[2], newsock.peeraddr[1])
    #broadcast_string( str, newsock )
  end # accept_new_connection
  
  def eval_msg(umsg,sock)
    unless /user_info:/.match(umsg).nil?
      first_message(umsg,sock)
      return 
    end
    unless /get_ads:/.match(umsg).nil?
      index = @descriptors.index(sock)
      sock.write("#{@user_info[index-1][:nickname]} from " +
                "#{@user_info[index-1][:channel]} => (underconstruction)sending ads...\n")
      return
    end 
  end
  
  def first_message(msg,sock)
    user_info = msg.split(" ")
    @user_info.push({:nickname => user_info[1], :channel => user_info[2]})
    str = sprintf("Welcome %s\n", user_info[1])
    sock.write(str)
    puts str
  end

  def broadcast_string( str, omit_sock )
    @descriptors.each do |clisock|
      if clisock != @serverSocket && clisock != omit_sock
        clisock.write(str)
      end
    end
    print(str)
  end 

end 