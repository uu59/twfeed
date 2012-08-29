# -- coding: utf-8

class TwitterClient
  class APIError < StandardError; end

  def initialize(tokens)
    @tokens = tokens
  end

  def request(method, path, params = {})
    params = params.each_pair.reject{|k,v| v.nil?}.inject({}){|r, (k,v)| r[k]=v; r}
    url = "https://#{params["host"] || "api.twitter.com"}#{path}"
    uri = URI.parse(url)
    c = OAuth::Consumer.new(@tokens[:consumer], @tokens[:consumer_secret], :site => "https://#{uri.host}")
    a = OAuth::AccessToken.new(c, @tokens[:token], @tokens[:token_secret])
    method = method.to_s.downcase
    res = case method
      when "get", "delete", "head"
        a.__send__(method, url + "?" + URI.encode_www_form(params))
      when "post", "put"
        a.__send__(method, url, params)
    end
    if res.code.to_i == 200
      res.body
    else
      raise APIError.new("code: #{res.code}, url: #{url}, method: #{method.upcase}, params: #{params}, body:\n#{res.body}")
    end
  end

  def self.define_api(name, path, method=:get, default_param={})
    class_eval <<-RUBY
      def #{name}(params = {})
        default_param = MultiJson.load <<-JSON
        #{MultiJson.dump(default_param.dup)}
        JSON
        query = default_param.merge(params)
        sprintf = {}
        "#{path}".scan(/%<(.*?)>/).each do |tmp|
          key = tmp.first
          sprintf[key.to_sym] = query.delete(key) || query.delete(key.to_sym)
        end
        request(:#{method}, "#{path}" % sprintf, query)
      end
    RUBY
  end

  define_api :rate_limit, "/1/account/rate_limit_status.json"
  define_api :list, "/1/lists/statuses.atom", :get, :per_page => 100
  define_api :user_timeline, "/1/statuses/user_timeline.atom", :get, :include_entities => true, :include_rts => true
  define_api :search, "/search.atom", :get, :host => "search.twitter.com", :rpp => 200, :include_entities => true
end
