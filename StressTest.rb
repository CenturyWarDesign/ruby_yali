require File.expand_path('../RobotPool.rb', __FILE__)

@pool=RobotPool.new
@pool.hostAddress="http://52.24.242.98:80"
# @pool.hostAddress="http://127.0.0.1:80"

@robotBehavior=lambda{
|robot|
  robot.open(
	  # lambda{
	    # rand(20).times{
	      # robot.guestlogin(lambda{
	        # robot.login(lambda{
	        	# rand(20).times{
		          # robot.loginwithtoken(lambda{
		          	 # robot.checkuser(lambda{
		          	 	# robot.setgameinfo(lambda{
		          	 	# 		robot.createOrder(lambda{
									# robot.updateOrder(lambda{
									# })
									# sleep(1)
								# })
								# sleep(1)
		          		# })
		          		# sleep(1)
		          	# })
		          # })
		          # sleep(1)
		      # }
	        # })
	      # })
	      # sleep(1)
	    # }
	    # robot.kill()
	  # },
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
	File.open("Account.txt","r") do |file|
		while line  = file.gets
			arr=line.split(' ')
			user_id=arr[0]
			login_token=arr[1]
			robot=@pool.generateRobot()
			s = nil
			s = lambda{|x|
				x.loginwithtoken(s)
			}
			robot.behavior=lambda{|r|
			  r.loginwithtoken(lambda{
					r.loginwithtoken(lambda{
						r.loginwithtoken(lambda{
							r.loginwithtoken(lambda{
								r.loginwithtoken(lambda{
									r.loginwithtoken(lambda{
										r.loginwithtoken(lambda{
										})
									})
								})
							})
						})
					})
				})
			}
			robot.user.userId=user_id
			robot.user.loginToken=login_token
			robot.run()
		end
	end
end

@maxcount=400

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
