require 'opentok'
key, secret = "15793291", "b6f90ff600f642f98b00d044161cbee6996045ed"


unless Rails.env.production?
  CONFIG = YAML.load_file("#{Rails.root}/config/config.yml")[Rails.env]
  ENV['FB_APP_ID'] = CONFIG['FB_APP_ID']
  ENV['FB_APP_SECRET'] = CONFIG['FB_APP_SECRET']
  ENV['FB_CALLBACK_URL'] = CONFIG['FB_CALLBACK_URL']
end

if Rails.env.production?
  TOKBOX = OpenTok::OpenTokSDK.new ENV['TOKBOX_KEY'], ENV['TOKBOX_SECRET'], :api_url => 'https://api.opentok.com/hl'
else
  TOKBOX = OpenTok::OpenTokSDK.new key, secret
end
