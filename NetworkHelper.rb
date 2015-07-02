require "net/http"
require "uri"

module NetworkHelper
  def self.requestConnect(url,params,callback)
    begin
      uri = URI.parse(url)
      res = Net::HTTP.post_form(uri, params)
      callback.call(res.code.to_i,res.body)
    rescue
      callback.call(-1,$!)
    end
  end

end

