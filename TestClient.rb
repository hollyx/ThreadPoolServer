require 'socket'      # Sockets are in standard library

hostname = 'localhost'
port = 2000
threads = []

for i in 0..15
	sleep 1
	server = TCPSocket.open(hostname, port)
		server.puts "HELO text\n"
		puts "message sent to server"
		line = server.gets   # Read lines from the socket
		puts line     # And print with platform line terminator
		server.close               # Close the socket when done
end

server = TCPSocket.open(hostname, port)
server.puts "KILL_SERVICE\n"
line = server.gets   # Read lines from the socket
puts line     # And print with platform line terminator
server.close 
#line = server.gets   # Read lines from the socket
#puts line     # And print with platform line terminator