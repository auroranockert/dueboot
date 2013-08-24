require 'serialport'

PORT = "tty.usbmodem411"

ARDUINO = "#{ENV['HOME']}/Applications/Arduino.app/Contents/Resources/Java/"

def execute cmd
  result = `#{cmd}`
  puts result unless result == ''
end

SerialPort.open("/dev/#{PORT}", 1200) {|sp| puts "Reset Board" }

# Upload to Board
puts "Upload to Flash"
execute "#{ARDUINO}/hardware/tools/bossac --port=#{PORT} -U false -e -w -v -b #{ENV['PWD']}/blinky.bin -R"
