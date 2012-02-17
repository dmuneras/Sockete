module ProtocolLogic

  @@editor_pwd = "editor"
  @@admin_pwd = "admin"
  @@cmd_client = %w[set_mode: get_ads: channel_list rm_channel: add_channel: my_channels]
  @@cmd_editor = %w[create_ad: rm_msg: pwd: ads_list ]
  @@cmd_admin =  %W[add_channel: rm_channel: channel_list change_pwd: change_editor_pwd: pwd:]
  @@mode = %w[push pull]


  def eval_first_msg(umsg,sock)
    user_info = umsg.split(" ")
    if umsg =~ /user_info:/
      @user_info.push({:nickname => user_info[1],:role => "client", :channels => [], :mode => "pull"})
      sock.write("Welcome #{user_info[1]}\n")
    elsif (umsg =~ /source_info:/) 
      @user_info.push({:nickname => user_info[1],:role => "editor",:status => "logging"}) 
      sock.write("password:\n")
    elsif (umsg =~ /admin_info:/ )
      @user_info.push({:nickname => user_info[1],:role => "admin", :status => "logging"}) 
      sock.write("password:\n")
    end 
  end
  
  def response_request(msg,sock)
    begin 
      @user = @user_info[@descriptors.index(sock)-1]
      msg = msg.strip
      umsg = msg.split(" ")
      cmd = umsg[0]
      case @user[:role]
      when "client"
        if @@cmd_client.include? cmd
          evaluate_client(umsg,sock)
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

  def evaluate_client(umsg,sock)
    case umsg[0]
    when "channel_list"
      sock.write("Channels: #{@channels.join(",")}\n")    
    when "add_channel:"
      channel = umsg[1]
      if @channels.include? channel
        @user[:channels] = @user[:channels] | [channel]
        sock.write("Channel added\n")
      else
        sock.write("Channel #{channel} doesnt exist\n")
      end
    when "my_channels"
      sock.write("#{list_to_print("MY CHANNELS",@user[:channels])}\n")
    when "rm_channel:"
      channel = umsg[1]
      if @user[:channels].include? channel
        @user[:channels].delete(channel)
        sock.write("Channel removed\n")
      else
        sock.write("Channel #{channel} is not present in your list\n")
      end
    when "set_mode:"
      if @@mode.include? umsg[1]
        @user[:mode] = umsg[1]
        sock.write("Now your mode is: #{umsg[1]}\n")
      else
        sock.write("Invalid mode: #{umsg[1]}\n")
      end
    when "get_ads:"
      if @user[:mode] == "pull"
        sock.write("Underconstruction\n")
      else
        sock.write("You have to change your mode to pull\n")
      end
    end
  end

  def evaluate_editor(umsg,sock)
    case umsg[0]
    when "pwd:"
      puts "Password: " + umsg[1]
      evaluate_pwd(umsg,sock)
    when "create_ad:"
      create_ad(umsg,sock)
    when "ads_list"
      if @msg_queue.size > 0 
        sock.write("Message queue #{@msg_queue.join(" \n ")}\n") 
      else
        sock.write("Nothing in message queue\n")
      end
    end
  end

  def evaluate_admin(umsg,sock)
    case umsg[0]
    when "pwd:"
      evaluate_pwd(umsg,sock) 
    when "add_channel:"
      channel = umsg[1]
      unless @channels.include? channel
        @channels.push(channel) 
        sock.write("Channel added\n")
      else
        sock.write("The channels already exits\n")
      end
    when "rm_channel:"
      if @channelS.include? channel
        @channels.delete(channel)
        sock.write("Channel was removed\n")
      else
        sock.write("Channel doesn't exist\n")
      end
    when "channel_list"
      sock.write("#{list_to_print("CHANNELS",@channels)}\n")
    end
  end

  def create_ad(umsg,sock)
    channel = umsg[1]
    msg = umsg - umsg[0..2]
    if @channels.include? channel
      msg = {:id => @msg_queue.size,:channel => channel, :ad => msg.join(" "), :send => false}
      @msg_queue.push(msg)
      sock.write("Message successfully created. Channel => #{channel}\n")
      send_channel_msg(msg[:ad],msg[:channel])
    else
      sock.write("Channel #{channel} doesnt exist\n")
    end
  end

  def evaluate_pwd(umsg,sock)
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
  
  def list_to_print(title,list)
    line = "| " 
    1.upto(title.size){line << "-"}
    title = "| " + title + "     | \n" + line + "     | \n"
    return title + (list.collect {|x| " =>" + x }).join("\n")
  end
  
  def send_channel_msg( ad, channel )
    @descriptors.each do |sock|
      if sock != @serverSocket
        user = @user_info[@descriptors.index(sock)-1] 
        unless user[:channels].nil?
          str = "Advice from channel #{channel} : #{ad}\n"
          sock.write(str) if user[:channels].include? channel
          puts str
        end
      end
    end
  end
end