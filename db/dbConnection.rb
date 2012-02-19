root = File.dirname(__FILE__)
$:.unshift root

require 'sqlite3'

class DbConnection 
  
  
  def initialize
    puts "INCIANDO DB..."
    @db =  SQLite3::Database.new "db/advice.db"
  end
  
  def insert_user nickname
    begin
      @db.execute "insert into user (nickname) values ('#{nickname}')"
    rescue => e
      puts "Something happend inserting user#{e}"
    end
  end

  def insert_channel channel
     begin
        @db.execute "insert into channel (channel_name) values ('#{channel}')"
      rescue => e
        puts "Something happend  inserting channel #{e}"
      end
  end
  
  def remove_channel channel
     begin
        @db.execute "delete from channel where channel_name = '#{channel}')"
      rescue => e
        puts "Something happend  inserting channel #{e}"
      end
  end
  
  def insert_advice(ad, channel_name)
    begin
      channel_id = (@db.execute "SELECT channel_id from channel WHERE channel_name = '#{channel_name}'")
      @db.execute "insert into advice (message , channel_id , date) values ('#{ad}','#{channel_id[0][0]}','#{Time.now}')"
      ad_id = (@db.execute "SELECT advice_id from advice WHERE channel_id = '#{channel_id[0][0]}' and message = '#{ad}'")
      return ad_id[0][0]
    rescue => e
      puts "Something happend inserting ad #{e}"
    end
  end
  
  def remove_advice(ad_id)
     begin
       @db.execute "delete from advice where advice_id = '#{ad_id}' "
     rescue => e
       puts "Something happend inserting ad #{e}"
     end
   end
  
  def register_sent_ad(nickname,advice_id,time)
    begin
      @db.execute "insert into log (nickname,advice_id,time) values ('#{nickname}','#{advice_id}','#{time}')"
    rescue => e
      puts "Something happend updating log #{e}"
    end
  end
  
  def subscribe(channel,nickname)
     channel_id = (@db.execute "SELECT channel_id from channel WHERE channel_name = '#{channel}'")
     user_id =  (@db.execute "SELECT user_id from user WHERE nickname = '#{nickname}'")
     @db.execute "insert into subscription (channel_id,user_id) values ('#{channel_id[0][0]}','#{user_id[0][0]}')"
  end
  
  def unsubscribe(channel,nickname)
    channel_id = (@db.execute "SELECT channel_id from channel WHERE channel_name = '#{channel}'")
    user_id =  (@db.execute "SELECT user_id from user WHERE nickname = '#{nickname}'")
    @db.execute "delete from subscription where channel_id = '#{channel_id[0][0]}' and user_id = '#{user_id[0][0]}'"
  end
  
  def fill_channels
    channels = []
    @db.execute( "SELECT channel_name from channel" ) do |channel|
      channels.push(channel[0].to_s)
    end
    return channels
  end
  
  def fill_queue_msg
    queue = []
    advices = @db.execute( "SELECT advice_id , channel_id , message , date from advice" )
    if advices.size <= 10
      for advice in advices
        channel = (@db.execute "SELECT channel_name from channel WHERE channel_id = '#{advice[1]}'")[0][0]
        ad =  {:id => advice[0] , :channel => channel , :ad => advice[2], :time => advice[3] }
        queue.push(ad)
      end
    else
      advices.size.downto(advices.size - 10) { |i|
        data = advices[i-1]
        channel = (@db.execute "SELECT channel_name from channel WHERE channel_id = '#{data[1]}'")[0][0]
        ad =  {:id => data[0].to_i , :channel => channel , :ad => data[2], :time => data[3] }
        queue.push(ad)
      }
    end
    return queue
  end
  
  def fill_channels_user nickname
     channels = @db.execute( "SELECT c.channel_name from channel c , subscription s, user u where s.user_id = u.user_id 
                            and s.user_id = u.user_id and s.channel_id = c.channel_id and u.nickname = '#{nickname}'" )
    return channels.collect{|x| x = x[0]}
  end
  
end