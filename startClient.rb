root = File.dirname(__FILE__)
$:.unshift root + "/models"

require "rubygems"
require "adsClient"

unless ARGV.length == 4
  STDERR.puts "Usage: #{$0} <nickname> <channel> <host> <port>"
  exit 1
end

$nickname, $channel, $host, $port = ARGV
client = AdsClient.new($nickname,$channel, $host,$port)