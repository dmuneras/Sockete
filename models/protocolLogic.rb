module ProtocolLogic
  
  @@editor_pwd = "editor"
  @@admin_pwd = "admin"
  @@cmd_client = %w[set_mode: get_ads: channel_list rm_from_channel: add_to_channel: my_channels]
  @@cmd_editor = %w[create_msg: rm_msg: pwd: ]
  @@cmd_admin =  %W[create_channel: rm_channel: channel_list change_pwd: change_editor_pwd: pwd:]
  
  def response_request(umsg,sock)
    begin 
      @user = @user_info[@descriptors.index(sock)-1]
      umsg = umsg.split(" ")
      cmd = umsg[0]
      case @user[:role]
        when "client"
          if @@cmd_client.include? cmd
            puts "Valid command"
          else
            raise Exception.new("#{@@cmd_client}")
          end
        when "editor"
          if @@cmd_editor.include? cmd
            evaluate_editor(umsg,sock) 
          else
            raise Exception.new("#{@@cmd_editor}")
          end
        when "admin"
          if @@cmd_admin.include? cmd
           evaluate_admin(umsg,sock)
          else
            raise Exception.new("#{@@cmd_admin}")
          end
      end
    rescue Exception => e
      sock.write("Invalid command: #{umsg[0]}\nValid Commands:#{e}\n")
    end
  end 

  def evaluate_editor(umsg,sock)
    case umsg[0]
      when "pwd:"
        evaluate_pwd(umsg,sock,@user)
    end
  end
  
  def evaluate_admin(umsg,sock)
    case umsg[0]
      when "pwd:"
        evaluate_pwd(umsg,sock,@user)
    end
  end
  
  def evaluate_pwd(umsg,sock,user)
     puts "Given password: #{umsg[1]}"
      if @user[:role] == "editor"
        pwd = @@editor_pwd
      else
        pwd = @@admin_pwd
      end
      if umsg[1] === pwd
        sock.write("Welcome\n")
        @user[:status] = "logged"
        puts "logged"
      else
        sock.write("password:\n")
      end
  end
end