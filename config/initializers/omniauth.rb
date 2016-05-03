Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_KEY'], ENV['GITHUB_CLIENT_SECRET']
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
end

OmniAuth.config.full_host = Rails.env.development? ? 'http://localhost:3000' : ENV['FULL_HOST']