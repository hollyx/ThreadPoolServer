require 'socket' 
require 'thread'               

port = 2000
server = TCPServer.open(port)   
puts "Server connected"

max_threads = 3
threads = []

#currently multithreaded
loop {    
    threads << Thread.new(server.accept) { |client|
		kill ="KILL_SERVICE\n"

		read = client.gets
		puts read

		if read[0,4] == "HELO"
			read = read.dump
			message="#{read} IP:#{client.peeraddr} Port:#{port} StudentID:11421218\n"
			client.puts message
		end

		if read==kill
			client.puts "Killing Server"
			client.close
			at_exit { p.shutdown }
			server.close
		end
    }
}

threads.each { |aThread|  aThread.join }