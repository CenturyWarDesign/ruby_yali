require "rubygems"
require "uri"
require "json"
require 'digest/sha1'
require 'digest/md5'
require File.expand_path('../AES.rb', __FILE__)

$DEBUG=false

class HttpTester
  attr_accessor :requestURL
  attr_accessor :appKey
  attr_accessor :appId
  attr_accessor :channelId
  attr_accessor :testCount
  def initialize()
    @successCount=0
    @failCount=0
    @averageResponseTime=0.0
    @totalTime=0.0
    @AES=AES.new
    @SHA1KEY="99ed0f252347ee7aa130736b0e95b0da87942f68"
  end

  def test
    Thread.start{
      startTime=Time.now.to_f
      @testCount.times{
        str=rand(99999999).to_s(16)
        doRegister(str,str,"We Are All Bananas")
      #	doPingback(2)
      }
      costTime=(Time.now.to_f-startTime)*1000
      @createRequestTime=costTime
    }
    Thread.start{
      startTime=Time.now.to_f
      while(true)
        #       system "clear"
        puts "success : #{@successCount}"
        puts "failed : #{@failCount}"
        puts "averageResponseTime : #{@averageResponseTime}ms"
        break if @testCount<=@successCount+@failCount
        sleep(1)
      end
      costTime=(Time.now.to_f-startTime)*1000
      #     system "clear"
      puts "success : #{@successCount}"
      puts "failed : #{@failCount}"
      puts "averageResponseTime : #{@averageResponseTime}ms"
      puts ""
      puts "create #{@testCount} request in #{(@createRequestTime/1000)}s"
      puts "finish #{@testCount} request in #{costTime/1000}s"
      puts "average response time : #{(@averageResponseTime)}ms"
    }
  end

  #  private

  def doRegister(username,password,displayName)
    params={}
    params.store("username",username)
    params.store("password",password)
    params.store("display_name",displayName)
    params.store("app_id",@appId)
    params.store("channel_id",@channelId)
    params.store("udid","TEST_UDID")
    params.store("lang","en")
    startTime=Time.now.to_f
    requestConnect("#{@requestURL}/api/usercenter/register",params,lambda{
      |code|
        if code==200
          costTime=(Time.now.to_f-startTime)*1000
          @successCount+=1
          @totalTime+=costTime
          @averageResponseTime=@totalTime/@successCount
          puts "register success : #{username} , #{password}"
          doLogin(username,password)
        else
          @failCount+=1
        end
    })
  end

  def doLogin(username,password)
    params={}
    params.store("username",username)
    params.store("password",Digest::MD5.hexdigest(password))
    params.store("app_id",@appId)
    params.store("channel_id",@channelId)
    params.store("udid","TEST_UDID")
    params.store("lang","en")
    startTime=Time.now.to_f
    requestConnect("#{@requestURL}/api/usercenter/login",params,lambda{
      |code,json|
        if code==200
          costTime=(Time.now.to_f-startTime)*1000
          @successCount+=1
          @totalTime+=costTime
          @averageResponseTime=@totalTime/@successCount
          puts "login success : #{json}"
        else
          @failCount+=1
        end
    })
  end

  def doCreateOrder()
    params={}
    params.store("username",username)
    params.store("password",password)
    params.store("app_id",@appId)
    params.store("channel_id",@channelId)
    params.store("udid","TEST_UDID")
    params.store("lang","en")
    startTime=Time.now.to_f
    requestConnect("#{@requestURL}/api/usercenter/login",params,lambda{
      |code|
        if code==200
          costTime=(Time.now.to_f-startTime)*1000
          @successCount+=1
          @totalTime+=costTime
          @averageResponseTime=@totalTime/@successCount
        else
          @failCount+=1
        end
    })
  end

  def doPingback(pingbackType)
    pingbackArr=["login","begin_session","end_session"]
    params={}
    params.store("sdk_version","1.0")
    params.store("user_id","-1")
    params.store("session_id","TEST_SESSION_ID")
    params.store("timestamp","11111111")
    params.store("app_id",@appId)
    params.store("channel_id",@channelId)
    params.store("udid","TEST_UDID")
    params.store("lang","en")
    startTime=Time.now.to_f
    requestConnect("#{@requestURL}/api/pingback/#{pingbackArr[pingbackType]}",params,lambda{
      |code|
        if code==200
          costTime=(Time.now.to_f-startTime)*1000
          @successCount+=1
          @totalTime+=costTime
          @averageResponseTime=@totalTime/@successCount
        else
          @failCount+=1
        end
    })

  end

  def requestConnect(url,params,callback)
    Thread.start{
      begin
        json=JSON.generate(params)
        sign=sha1("#{URI.encode(json)}#{@appKey}")
        jsonMap={}
        jsonMap.store("data",URI.encode(json))
        jsonMap.store("sign",sign)
        finalParams={}
        finalParams.store("a",@AES.cipher(JSON.generate(jsonMap)))
        uri = URI.parse(url)
        puts "request url : #{url}" if $DEBUG
        puts "params : #{params}" if $DEBUG
        res = Net::HTTP.post_form(uri, finalParams)
        if res.code.to_i==200
          puts "res : #{res.body}" if $DEBUG
        else
          puts "res : #{res.code.to_i}" if $DEBUG
        end
        callback.call(res.code.to_i,JSON.load(res.body))
      rescue
        puts "Connect Failed : #{$!}"
      callback.call(-1)
      end
    }
  end

  def sha1(input)
    outStr=""
    Digest::SHA1.hexdigest(input).each_char.with_index{
    |c,index|
      outStr+=(c.to_i(16) ^ @SHA1KEY[index].chr.to_i(16)).to_s(16)
    }
    return outStr
  end

end

