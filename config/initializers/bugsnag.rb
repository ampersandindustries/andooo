Bugsnag.configure do |config|
  config.api_key = "25494b0dde8f7d4d7594349f1bfdece9"
  config.notify_release_stages = ["staging", "production"]
end

class BugsnagError < RuntimeError
  include Bugsnag::MetaData
end
