require "json"
require 'digest/sha1'
require File.expand_path('../NetworkHelper.rb', __FILE__)
require File.expand_path('../AES.rb', __FILE__)
require File.expand_path('../Robot.rb', __FILE__)

$LOG=true
class RobotPool
  attr_accessor :hostAddress
  def initialize()
    @appId="100"
    @appKey="bf2eee982aa6e50c1d98823ba6fc134b"
    @channelId="1"
    @robotArr=[]

    @successCount=0
    @thissuccessCount=0
    @thissuccessTime=0.0
    @thisageTime=0.0
    @thisfailCount=0

    @failCount=0
    @averageResponseTime=0.0
    @totalTime=0.0
    @AES=AES.new
    @SHA1KEY="99ed0f252347ee7aa130736b0e95b0da87942f68"
  end
  def robotcount
    return @robotArr.count
  end

  def run
    @robotArr.each{
    |robot|
      robot.run
    }
    sleep
  end

  def showLog
    puts "-------------------------------------------------------------------------------------"
    puts "Robot Count     : #{@robotArr.count}"
    puts "Connect Success : #{@successCount}"
    puts "Connect Failed  : #{@failCount}"
    puts "Connect AveTime : #{@averageResponseTime} ms"
    puts "This success : #{@thissuccessCount}"
    puts "This failed : #{@thisfailCount}"
    puts "This AveTime : #{@thisageTime} ms"
    puts "-------------------------------------------------------------------------------------"
    @thissuccessCount=0
    @thissuccessTime=0.0
    @thisfailCount=0
  end

  def generateRobot
    r=Robot.new(self)
    pushRobot(r)
    return r
  end

  def pushRobot(robot)
    @robotArr << robot
  end

  def removeRobot(robot)
    @robotArr.delete(robot)
  end

  def requestConnect(url,params,callback)
    Thread.start{
      params.store("app_id",@appId)
      params.store("channel_id",@channelId)
      json=JSON.generate(params)
      sign=sha1("#{URI.encode(json)}#{@appKey}")
      jsonMap={}
      jsonMap.store("data",URI.encode(json))
      jsonMap.store("sign",sign)
      finalParams={}
      finalParams.store("a",@AES.cipher(JSON.generate(jsonMap)))

      startTime=Time.now.to_f
      NetworkHelper::requestConnect("#{@hostAddress}#{url}",finalParams,lambda{
      |code,res|
        costTime=(Time.now.to_f-startTime)*1000
        if code==200
          @successCount+=1
          @totalTime+=costTime
          @averageResponseTime=@totalTime/@successCount

          @thissuccessCount+=1
          @thissuccessTime+=costTime
          @thisageTime=@thissuccessTime/@thissuccessCount

          json=JSON.load(res)
          if(json!=nil)
            callback.call(json['ret'],json['data'])
          else
            callback.call(-3,nil)
          end
        else
          @failCount+=1
          @thisfailCount+=1
          callback.call(code,res)
          puts "#{code}#{@hostAddress}#{url}"
        end
      })
    }
  end

  private

  def sha1(input)
    outStr=""
    Digest::SHA1.hexdigest(input).each_char.with_index{
    |c,index|
      outStr+=(c.to_i(16) ^ @SHA1KEY[index].to_i(16)).to_s(16)
    }
    return outStr
  end

end
