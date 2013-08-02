require 'rubygems'
require 'bundler'

Bundler.setup :default, :development, :example
require 'sinatra'
require 'omniauth'
require 'omniauth-sharedcookie'

SCOPE = 'friends,audio'

use Rack::Session::Cookie

use OmniAuth::Builder do
  provider :sharedcookie, :login_url => '/login', :cookie_name => 'auth_cookie', :encryption_key => 'LXWRMxv84CsXvZVWm2gQ3AKcZf7e7rpR', :hmac_key => '53HGbrQJLq5iXIhPhU9JM2259WfgqCr6'
end

get '/' do
  <<-HTML
  <ul>
    <li><a href='/auth/sharedcookie'>Sign in using an encrypted shared cookie</a></li>
  </ul>
  HTML
end

get '/login' do
  response.set_cookie('auth_cookie',
    :value => 'r1UZ04l6GBpR9+mg+OwJQAlwHT5yJ5xOe9KWCgfBOhHE6JJCxf87qzuyDYIMgQJCdOurRyGcopSLAg09RbWEGFuMFUQQ1g7krQfgrk/PRiIkTGMwfq0nvRCFPIT9o5yEbbwbjuchj402CiD/+OwKyA==')
  <<-HTML
    <p>Done. Go to the <a href='/auth/sharedcookie/callback'>callback</a></p>
  HTML
end

get '/auth/:provider/callback' do
  content_type 'text/plain'
  request.env['omniauth.auth'].info.to_hash.inspect
end
