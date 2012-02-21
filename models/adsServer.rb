require "socket"
require "protocolLogic"

class AdsServer

  include ProtocolLogic
  def initialize( host,port )
    @user_info = []
    @descriptors = []
    @channels = []
    @msg_queue = []
    @serverSocket = TCPServer.new( host, port )
    @serverSocket.setsockopt( Socket::SOL_SOCKET, Socket::SO_REUSEADDR, 1 )
    printf("adsServer started on port %d\n", port)
    @descriptors.push( @serverSocket )
    fill_general_info
  end 

  #Metodo para iniciar el servidor, empezando a seleccionar con el metodo select los clientes que tienen eventos y respondiendo 
  #a sus request
  def run
    while true
      begin
        res = select( @descriptors, nil, nil)
        if res != nil 
          for sock in res[0]
            if sock == @serverSocket 
              accept_new_connection
            elsif sock.eof? 
              sock.close
              @user_info.delete(@user_info[@descriptors.index(sock)-1])
              @descriptors.delete(sock)
            else
              msg = sock.gets()
              puts msg
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
  #Metodo para aceptar una nueva conexion de un cliente.
  def accept_new_connection
    newsock = @serverSocket.accept
    @descriptors.push( newsock )
  end   
end 