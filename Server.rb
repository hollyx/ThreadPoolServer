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

ipAddress = ARGV[0]
port = ARGV[1]
studentId = ARGV[2]

threadPool = Pool.new(3)
server = TCPServer.open(port)   
puts "Server connected"

loop {    
		threadPool.schedule do
			client = server.accept
			for i in 0..2 
				read = client.gets
				puts read

				if read[0,4] == "HELO"
					#read = read.dump 	#get rid of '\n' at end of message
					message="#{read}IP:#{ipAddress}\nPort:#{port}\nStudentID:#{studentId}\n"
					client.puts message
				elsif read == "KILL_SERVICE\n"
					puts "server kill requested"
					client.puts "Killing Server"
					client.close
					at_exit { threadPool.shutdown }
					server.close
					puts "Server closed"
					exit
				else
					puts "new command"
				end
			end
		end
}
