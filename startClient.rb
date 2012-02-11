root = File.dirname(__FILE__)
$:.unshift root + "/models"

require "adsClient"
require "adsSource"
require "adsAdmin"

unless ARGV.length == 4
  STDERR.puts "Usage: #{$0} <nickname> <role> <host> <port>\nrole = client | editor | admin"
  exit 1
end

$nickname, $role, $host, $port = ARGV
case $role
when "client"
  client = AdsClient.new($nickname,$host,$port)
when "editor"
  editor = AdsSource.new($nickname,$host,$port)
when "admin"
  admin = AdsAdmin.new($nickname,$host,$port)
else
  STDERR.puts "Wrong role\nrole = client | editor | admin"
end