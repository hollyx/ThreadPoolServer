require 'socket' 
require 'thread'

class Pool
  def initialize(size)
    @size = size
    @jobs = Queue.new
    
    @pool = Array.new(@size) do |i|
		Thread.new do
        Thread.current[:id] = i

        catch(:exit) do
          loop do
           
            job, args = @jobs.pop
            job.call(*args)
          end
        end
      end
    end
  end

  def schedule(*args, &block)
    @jobs << [block, args]
  end

  def shutdown
    @size.times do
      schedule { throw :exit }
    end
    @pool.map(&:join)
  end
end              

port = ARGV[0]
threadPool = Pool.new(3)
server = TCPServer.open(port)   
puts "Server connected"

loop {    
		threadPool.schedule do
			read = client.gets
			puts read

			if read[0,4] == "HELO"
				read = read.dump 	#get rid of '\n' at end of message
				message="#{read} IP:#{client.peeraddr} Port:#{port} StudentID:11421218\n"
				client.puts message
			elsif read=="KILL_SERVICE\n"
				client.puts "Killing Server"
				client.close
				at_exit { threadPool.shutdown }
				server.close
			else #new message type
				puts "new message type"
			end
		end
		server.close
}
