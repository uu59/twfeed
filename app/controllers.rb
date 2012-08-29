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
end
