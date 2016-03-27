require "sinatra"
require "instagram"
require "yaml"
require "json"

# Load the 'client_config.yaml' file
config_yaml = YAML.load_file("client_config.yaml")
instagram_config = config_yaml["instagram"]

enable :sessions

# Set up the Instagram client
CALLBACK_URL = instagram_config["callback_url"]
Instagram.configure do |config|
  config.client_id = instagram_config["client_id"]
  config.client_secret = instagram_config["client_secret"]
end


get "/" do
  '<a href="/oauth/connect">Connect with Instagram</a>'
end

get "/oauth/connect" do
  redirect Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
end

get "/oauth/callback" do
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)
  session[:access_token] = response.access_token
  redirect "/nav"
end


get "/nav" do
  html =
  """

    <h1>Ruby Instagram Gem Sample Application</h1>

    <ol>
      <1i><a href='/parse_data'>Go Parsing</a></li>
    </ol>

    <ol>
      <1i><a href='/view_test'>Go Image View</a></li>
    </ol>

  """

  html

end

get "/parse_data" do
  html =
  """
  <form action='/parse_data' method='post'>
    First name: <input type='text' name='tagName'><br>
    <input type='submit' value='Submit'>
  </form>
  """

  html
end

post "/parse_data" do
  # Set up the client
  client = Instagram.client(access_token: session[:access_token])
  tags = client.tag_search(params[:tagName])
  begin
    tag_recent_media = client.tag_recent_media(tags[0].name, 100)
  rescue 
    return "#{params[:tagName]} is not exist. Try again with another tag name"
  end

  # Parse the data
  datas = []
  tag_recent_media.each do |media_item|
    object = {}
    object["storeName"] = store_name(media_item)
    object["imgUrl"] = media_item.images.standard_resolution.url
    datas.push(object)
  end

  # Write the json data
  file = File.open("data.json", "w")
  file.write(JSON.generate(datas))

  html = "<h1> Success  </h1><br><a href='/nav'>Go home</a>"
  html
end

get "/view_test" do
  file = File.open("data.json", "r")
  data = JSON.parse(file.read())
  html =''
  data.each do |media|
    html  << "<h1> #{media['storeName']} </h1>" << "<img src=#{media['imgUrl']}/>"
  end

  html
end

def store_name(item)
  if item.location
    item.location.name
  else
    item.caption.text.split('#')[2]
  end
end
