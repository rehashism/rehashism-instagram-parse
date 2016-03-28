# Simple Instagram Parser

## Requirements
Install 'sinatra' gem:
````
gem install sinatra
````

Install 'instagram' gem:
````
 gem install instagram
````

## instagram Configurations
Go [Instagram Developer
Page](https://www.instagram.com/developer/clients/manage/).
 1. Set 'REDIRECT URL' : YOUR_SERVER.com/oauth/callback.
 2. Copy that into 'client_config.yaml' file.

## Run
Run sinatra server:
````
ruby parse.rb -p YOUR_PORT -o YOUR_SERVER
````

## JSON Data
[
  {
    "storeName" : "name",
    "imgUrl" : "url",
  },
  ...
]
