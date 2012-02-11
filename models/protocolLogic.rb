module ProtocolLogic
  
  @@editor_pwd = "editor"
  @@admin_pwd = "admin"
  @@cmd_client = %w[set_mode: get_ads: channel_list rm_from_channel: add_to_channel: my_channels]
  @@cmd_editor = %w[create_msg: rm_msg: ]
  @@cmd_admin =  %W[create_channel: rm_channel: channel_list change_pwd: change_editor_pwd:]
  
  def response_request(umsg,sock)
    begin 
      role = @user_info[@descriptors.index(sock)-1][:role]
      umsg = umsg.split(" ")
      case role
        when "client"
          if @@cmd_client.include? umsg[0]
            puts "Valid command"
          else
            raise Exception.new("#{@@cmd_client}")
          end
        when "editor"
          if @@cmd_editor.include? umsg[0]
            puts "Valid command"
          else
            raise Exception.new("#{@@cmd_editor}")
          end
        when "admin"
          if @@cmd_admin.include? umsg[0]
            puts "Valid command"
          else
            raise Exception.new("#{@@cmd_admin}")
          end
      end
    rescue Exception => e
      sock.write("Invalid command: #{umsg[0]}\nValid Commands:#{e}\n")
    end
    end 


  end