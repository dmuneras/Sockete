root = File.dirname(__FILE__)
$:.unshift root + "/models" 
 
require "adsServer"
require "protocolLogic"

unless ARGV.length == 2
  STDERR.puts "Usage: #{$0} <host> <port>"
  exit 1
end

$host, $port = ARGV
server = AdsServer.new($host,$port)
server.run
