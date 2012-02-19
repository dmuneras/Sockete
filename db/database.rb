require 'sqlite3'

  # Open a database
  db = SQLite3::Database.new "advice.db"
  create = false
  if create
    # Create a database
    db.execute <<-SQL
    create table if not exists user (
      user_id  INTEGER PRIMARY KEY ASC,
      nickname varchar(30) UNIQUE
    );
    create table if not exists  channel(
      channel_id INTEGER PRIMARY KEY ASC,
      channel_name varchar(30) UNIQUE
    );
    create table if not exists subscription(
      user_id INTEGER,
      channel_id INTEGER 
    );
    create table if not exists advice(
      advice_id INTEGER PRIMARY KEY ASC,
      channel_id INTEGER,
      message varchar(30),
      date DATE
    );
    create table if not exists log(
      nickname varchar(30),
      advice_id INTEGER,
      date DATE
      CONSTRAINT PRIMARY KEY(nickname,advice_id)
    );
    SQL
  else
    # show tables
    db.execute( "SELECT name FROM sqlite_master
    WHERE type='table'
    ORDER BY name" ) do |row|
      p row
    end
  end
  
  
  # Execute a few inserts
  #{
  #  0 => "admin",
  #  1 => "carl",
  #}.each do |pair|
  #  db.execute "insert into user values ( ?, ? )", pair
  #end

  # Delete
  #db.execute( "DELETE from user" )
  
  #drop table
  #db.execute("DROP table advice.user")
  

  
   #Find tables into database
  #db.execute( "SELECT * from user" ) do |row|
  #  p row
  #end