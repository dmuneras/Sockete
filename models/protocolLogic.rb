root = File.dirname(__FILE__)
$:.unshift root + "/../db/" 

require "dbConnection"

module ProtocolLogic
  
  @@editor_pwd = "editor"
  @@admin_pwd = "admin"
  @@cmd_client = %w[set_mode: get_ads: channel_list rm_channel: add_channel: my_channels]
  @@cmd_editor = %w[create_ad: rm_ad: pwd: ads_list ]
  @@cmd_admin =  %W[add_channel: rm_channel: channel_list change_pwd: change_editor_pwd: pwd:]
  @@mode = %w[push pull]
  @@connection = DbConnection.new
  
  def eval_first_msg(umsg,sock)
    user_info = umsg.split(" ")
    if umsg =~ /user_info:/
      @user_info.push({:nickname => user_info[1],:role => "client", :channels => [], :mode => "pull", :time => Time.now})
      sock.write("Welcome #{user_info[1]}\n")
      @@connection.insert_user user_info[1]
      @user_info.last[:channels] = @@connection.fill_channels_user(user_info[1])
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
      puts "Comando ingresado: " +  cmd
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
        @@connection.subscribe(channel,@user[:nickname])
        sock.write("Channel #{channel} added\n")
      else
        sock.write("Channel #{channel} doesnt exist\n")
      end
    when "my_channels"
      sock.write("#{list_to_print("MY CHANNELS",@user[:channels])}\n")
    when "rm_channel:"
      channel = umsg[1]
      if @user[:channels].include? channel
        @user[:channels].delete(channel)
        @@connection.unsubscribe(channel,@user[:nickname])
        sock.write("Channel #{channel} removed\n")
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
      channel = umsg[1]
      if @user[:mode] == "pull" and @user[:channels].include? channel
        send_pull_msg(sock,channel)
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
        sock.write("#{list_to_print("Advices queue",@msg_queue)}\n") 
      else
        sock.write("Nothing in message queue\n")
      end
    when "rm_ad:"
     advice = @msg_queue[@msg_queue.index{|ad| puts ad; ad[:id] == umsg[1]}]
     puts advice
    end
  end

  def evaluate_admin(umsg,sock)
    case umsg[0]
    when "pwd:"
      evaluate_pwd(umsg,sock) 
    when "add_channel:"
      channel = umsg[1]
      unless @channels.include? channel
        @@connection.insert_channel channel
        @channels.push(channel) 
        sock.write("Channel added\n")
      else
        sock.write("The channels already exits\n")
      end
    when "rm_channel:"
      channel = umsg[1]
      if @channels.include? channel
        @@connection.delete_channel channel
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
      msg = {:id => 0 ,:channel => channel, :ad => msg.join(" "), :time => Time.now}
      ad_id = @@connection.insert_advice(msg[:ad],msg[:channel])
      msg[:id] = ad_id
      @msg_queue.push(msg)
      sock.write("Message successfully created. Channel => #{channel}\n")
      send_channel_msg(msg)
    else
      sock.write("Channel doesnt exist\n")
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
    return title + (list.collect {|x| " => #{x}" }).join("\n")
  end
  
  def send_channel_msg( msg)
    @descriptors.each do |sock|
      if sock != @serverSocket
        user = @user_info[@descriptors.index(sock)-1] 
        if user[:role] == "client"  and user[:mode] == "push"
          str = "Advice from channel #{msg[:channel]} : #{msg[:ad]}\n"
          sock.write(str) if user[:channels].include? msg[:channel]
          @@connection.register_sent_ad(user[:nickname],msg[:id],msg[:time])
        end
      end
    end
  end

  def send_pull_msg sock, channel
    to_send = []
    if !(@msg_queue.empty?)
      for msg in @msg_queue
        if channel == msg[:channel]
          str = "[channel : #{msg[:channel]} | content: #{msg[:ad]}]\n"
          to_send.push(str)
          @@connection.register_sent_ad(@user[:nickname],msg[:id],msg[:time])
        end
      end
      if !(to_send.empty?)
        sock.write("#{list_to_print("ADVICES FROM SERVER",to_send)}\n")
      else
        sock.write("Nothing to show\n")
      end
    else
      sock.write("Nothing to show\n")
    end
  end
  
  def fill_general_info
    @channels = @@connection.fill_channels
    @msg_queue = @@connection.fill_queue_msg
  end
  
end