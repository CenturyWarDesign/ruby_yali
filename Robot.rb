require 'digest/md5'

class Robot
  @@id=0

  attr_accessor :behavior
  attr_accessor :user
  def initialize(robotPool)
    @robotPool=robotPool
    @deviceInfo=Robot.generateDeviceInfo
    @udid=Robot.generateUDID
    @user=User.new
    @orderId=""
    @id=@@id
    @@id+=1
    @name="Robot - #{@id}"

    @running=false
    @runThread
  end

  def run
    if !@running
      @running=true
      @runThread=Thread.start{
        @behavior.call(self)
      }
    end
  end

  def kill
    stop()
    release()
  end

  def stop
    @runThread.kill()
  end

  def restart
    initialize
    #run
  end

  def release
    @robotPool.removeRobot(self)
  end

  def log(msg)
    puts "#{@name} : #{msg}"
  end

  def open(success=nil,fail=nil,rand_device_id=true)
	if rand_device_id
	  params=Robot.generateDeviceInfo.dup
	else
	  params=@deviceInfo.dup
	end
    params.store("user_id",@user.userId)
    params.store("timestamp",Time.now.to_f)
	if rand_device_id
		params.store("udid",Robot.generateUDID)
	else
	    params.store("udid",@udid)
	end
    @robotPool.requestConnect("/api/pingback/open",params,lambda{
    |code,data|
      if(code==0)
        success.call() if success!=nil
      else
        fail.call(code) if fail!=nil
      end
    })
  end

  def register(success=nil,fail=nil)
    params={}
    username=rand(999999999).to_s(16)
    password="password"
    displayName=@name
    params.store("username",username)
    params.store("password",password)
    params.store("display_name",displayName)
    params.store("udid",@udid)
    params.store("lang","zh")
    @robotPool.requestConnect("/api/usercenter/register",params,lambda{
    |code,data|
      if(code==0)
        @user.username=username
        @user.password=password
        @user.displayName=displayName
        @user.userId=data['user_id']
        success.call() if success!=nil
      else
        fail.call(code) if fail!=nil
      end
    })
  end

 def guestlogin(success=nil,fail=nil)
    params={}
    username=rand(999999999).to_s(16)
    params.store("udid",@udid)
    params.store("lang","zh")
    @robotPool.requestConnect("/api/usercenter/guest_login",params,lambda{
    |code,data|
      if(code==0)
        @user.username=data['username']
        @user.password=data['password']
        @user.userId=data['user_id']
        success.call() if success!=nil
      else
        fail.call(code) if fail!=nil
      end
    })
  end

  def login(success=nil,fail=nil)
    params={}
    params.store("username",@user.username)
    params.store("password",Digest::MD5.hexdigest(@user.password))
    params.store("udid",@udid)
    params.store("lang","en")
    @robotPool.requestConnect("/api/usercenter/login",params,lambda{
    |code,data|
      if(code==0)
        @user.userId=data['user_id']
        @user.loginToken=data['login_token']
        success.call() if success!=nil
      else
        fail.call(code) if fail!=nil
      end
    })
  end

  def loginwithtoken(success=nil,fail=nil)
    params={}
    params.store("user_id",@user.userId)
    params.store("login_token",@user.loginToken)
    params.store("udid",@udid)
    params.store("lang","en")
    @robotPool.requestConnect("/api/usercenter/login_with_token",params,lambda{
    |code,data|
      if(code==0)
        @user.userId=data['user_id']
        @user.loginToken=data['login_token']
        success.call() if success!=nil
      else
        fail.call(code) if fail!=nil
      end
    })
  end

  def createOrder(success=nil,fail=nil)
    params={}
    params.store("user_id",@user.userId)
    params.store("login_token",@user.loginToken)
    params.store("udid",@udid)
    params.store("lang","en")

    params.store("product_id","com.sevenga.rb.banana")
    params.store("product_name","Banana")
    params.store("product_description","BANANAS!!!!!!!!!!!!!!")
    params.store("currency","usd")
    params.store("amount",1)
    params.store("game_coin_amount",100)
    params.store("count",1)
    params.store("server_id","unknown")
    params.store("payment_type","ruby")

    @robotPool.requestConnect("/api/pay/create_order",params,lambda{
    |code,data|
      if(code==0)
        @orderId=data['sevenga_order_id']
        success.call() if success!=nil
      else
        fail.call(code) if fail!=nil
      end
    })
  end

  def updateOrder(success=nil,fail=nil)
    params={}

    params.store("sevenga_order_id",@orderId)
    params.store("user_id",@user.userId)
    params.store("status",3)
    params.store("udid",@udid)
    params.store("lang","en")

    @robotPool.requestConnect("/api/pay/update_order",params,lambda{
    |code,data|
      if(code==0)
        success.call() if success!=nil
      else
        fail.call(code) if fail!=nil
      end
    })
  end

  private

  def self.generateUDID
    return Digest::MD5.hexdigest("#{rand(999999)}#{Time.now.to_f}")
  end

  def self.generateDeviceInfo
    map={}
    map.store("sdk_version","1.0_1")
    map.store("session_id","NO_SESSION_ID")
    map.store("app_lang","zh")

    map.store("facebook_aid","123")
    map.store("os_name","Robot S-998")
    map.store("os_version","v9.9-beta")
    map.store("os_lang","zh")
    map.store("ip","10.0.0.208")
    map.store("mac","MAC")

    map.store("connection_type","Light")
    map.store("screen_resolution","999*999")
    map.store("mobile_operator","Made in China")
    map.store("carrier","Ruby")
    map.store("brand","BANANA")
    map.store("manufacturer","Sevenga")
    map.store("model","X-1")
    map.store("imei","9999999999999")
    map.store("imsi","9999999999999")
    map.store("android_id","99999")
    map.store("device_serial","DSKLFJOIWEHJ")
    map.store("country","Beijing")
    return map
  end
end

class User
  attr_accessor :username
  attr_accessor :password
  attr_accessor :displayName
  attr_accessor :loginToken
  attr_accessor :userId
  attr_accessor :email
end
