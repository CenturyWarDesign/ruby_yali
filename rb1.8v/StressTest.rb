require "net/http"
require File.expand_path('../HttpTester.rb', __FILE__)

tester=HttpTester.new
tester.appId="100"
tester.requestURL="http://www.sevenga.cn"
tester.appKey="bf2eee982aa6e50c1d98823ba6fc134b"
tester.channelId=1
tester.testCount=1
tester.test

sleep
