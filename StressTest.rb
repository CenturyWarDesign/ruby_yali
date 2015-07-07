require File.expand_path('../RobotPool.rb', __FILE__)

@pool=RobotPool.new
@pool.hostAddress="http://127.0.0.1:80"

@robotBehavior=lambda{
|robot|
  robot.open(
  lambda{
    rand(20).times{
      robot.guestlogin(lambda{
        robot.login(lambda{
          robot.loginwithtoken(lambda{
          	 # robot.checkuser(lambda{
          	 	robot.setgameinfo(lambda{
          	 	# 	robot.loginwithtoken(lambda{
          			# })
          		})
          	# })
          })
        })
      })
      sleep(1)
    }
    robot.kill()
  },
  lambda{
    robot.kill()
  }
  )
}

def makeRobot()
	robot=@pool.generateRobot()
	robot.behavior=@robotBehavior
	robot.run()
end

def loadRobotFromFile
	#File.open("Account.txt","r") do |file|
	#	while line  = file.gets
	#		arr=line.split(' ')
	#		username=arr[0]
	#		password=arr[1]
			robot=@pool.generateRobot()
			robot.behavior=lambda{
			|r|
				while(true)
				  r.open( lambda{
					r.register(lambda{
					  r.login(lambda{
						#r.createOrder(lambda{
						#	r.updateOrder(lambda{
						#	})
						#})
					  })
					})
				  })
				  sleep(0.05)
				end
			}
			#robot.user.username=username
			#robot.user.password=password
			robot.run()
	#	end
	#end
end

@maxcount=20

Thread.start{
	count=0
	while(count<@maxcount)
	# sleep(rand(2))
	# rand(5).times{
		makeRobot()
		count+=1
	# }
	end
}
# loadRobotFromFile

Thread.start{
	while(true)
		puts ""
		#@nowcount=0
		@nowcount=@pool.robotcount
		puts "Remain Robot : #{@nowcount}"
		while @nowcount<@maxcount
				makeRobot()
			@nowcount+=1
		end
		@pool.showLog()
		sleep(3)
	end
}

sleep
