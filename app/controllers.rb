# for params[:foo][:bar][:baz] => nil
class NilClass
  def [](*args)
    nil
  end
end

MyApp.namespace "/" do
  get do
    erb :index
  end

  get "feed" do
    client = TwitterClient.new(params)
    begin
      xml = client.__send__(params[:method], params[:query])
      content_type "application/xml"
      headers "X-Content-Type-Options" => "nosniff"
      xml
    rescue TwitterClient::APIError => ex
      @error = "Error"
      @ex = ex
      erb :index
    end
  end

  namespace "oauth" do
    get "/request" do
      consumer = OAuth::Consumer.new(params[:consumer], params[:consumer_secret], :site => "https://api.twitter.com")
      req = consumer.get_request_token(:oauth_callback => "http://#{request.host}:#{request.port}/oauth/auth")
      session[:consumer] = params[:consumer]
      session[:consumer_secret] = params[:consumer_secret]
      session[:token] = req.token
      session[:secret] = req.secret
      redirect req.authorize_url
    end

    get "/auth" do
      redirect "/oauth/request" unless session[:consumer]
      consumer = OAuth::Consumer.new(session[:consumer], [:consumer_secret], :site => "https://api.twitter.com")
      req = OAuth::RequestToken.new(consumer, session[:token], session[:secret])
      access = req.get_access_token(:oauth_verifier => params[:oauth_verifier])
      redirect "/"
    end
  end
end
