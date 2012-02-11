$:.unshift File.dirname(__FILE__) 
require "socket"
require "ProtocolLogic"

class AdsServer
  
  include ProtocolLogic
  def initialize( host,port )
    @user_info = []
    @descriptors = []
    @serverSocket = TCPServer.new( host, port )
    @serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
    printf("adsServer started on port %d\n", port)
    @descriptors.push( @serverSocket )
  end 

  def run
    while true
      begin
        res = select( @descriptors, nil, nil, nil)
        if res != nil then
          for sock in res[0]
            if sock == @serverSocket 
              accept_new_connection
            elsif sock.eof? 
              sock.close
              @user_info.delete(@user_info[@descriptors.index(sock)-1])
              @descriptors.delete(sock)
            else
              msg = sock.gets()
              user_info = @user_info[@descriptors.index(sock)-1]
              if (msg =~ /user_info:|source_info:|admin_info:/) and user_info.nil? 
                eval_first_msg(msg,sock) 
              elsif (msg =~ /user_info:|source_info:|admin_info:/) and !(user_info.nil?)
                sock.write("You are registered #{user_info[:nickname]}, do not try to deceive me\n")
              else
                response_request(msg,sock)
              end
            end
          end
        end
      rescue => e
        puts "Somenthing wrong happened #{e}"
      end
    end
  end 

  private
  def accept_new_connection
    newsock = @serverSocket.accept
    @descriptors.push( newsock )
  end 

  def eval_first_msg(umsg,sock)
    user_info = umsg.split(" ")
    if umsg =~ /user_info:/
      @user_info.push({:nickname => user_info[1],:role => "client", :channels => []})
      sock.write("Welcome #{user_info[1]}\n")
    elsif (umsg =~ /source_info:/) 
      @user_info.push({:nickname => user_info[1],:role => "editor",:status => "logging"}) 
      sock.write("password:\n")
    elsif (umsg =~ /admin_info:/ )
      @user_info.push({:nickname => user_info[1],:role => "admin", :status => "logging"}) 
      sock.write("password:\n")
    end 
  end

  def send_channel_msg( str, channel )
    @descriptors.each do |sock|
      if sock != @serverSocket 
        clisock.write(str)
      end
    end
    puts str
  end
end 