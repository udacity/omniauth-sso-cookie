require 'rubygems'
require 'bundler'

Bundler.setup :default, :development, :example
require 'sinatra'
require 'omniauth'
require 'omniauth-sharedcookie'
require 'base64'
require 'openssl'
require 'json'

ENCRYPTION_KEY = 'LXWRMxv84CsXvZVWm2gQ3AKcZf7e7rpR'
HMAC_KEY       = '53HGbrQJLq5iXIhPhU9JM2259WfgqCr6'

use Rack::Session::Cookie

use OmniAuth::Builder do
  provider :sharedcookie,
    :login_url => '/login', :cookie_name => 'auth_cookie',
    :uid_field => 'uid', :encryption_key => ENCRYPTION_KEY,
    :hmac_key => HMAC_KEY
end

get '/' do
  <<-HTML
  <ul>
    <li><a href='/auth/sharedcookie'>Sign in using an encrypted shared cookie</a></li>
  </ul>
  HTML
end

get '/login' do
  data = {
    uid: 12345,
    nickname: 'FizzBuzz',
    email: 'fizzbuzz@example.com',
    expires: (Time.now + 10*24*60*60*10).to_i,
  }

  cipher = OpenSSL::Cipher.new('aes-256-cbc')
  cipher.encrypt
  cipher.key = ENCRYPTION_KEY
  iv = cipher.random_iv
  encrypted = cipher.update(JSON.generate(data)) << cipher.final()
  encrypted = iv + encrypted
  encrypted = encrypted + OpenSSL::HMAC.digest('sha256', HMAC_KEY, encrypted)

  response.set_cookie('auth_cookie', :value => Base64.strict_encode64(encrypted).encode('utf-8'))
  <<-HTML
    <p>Done. Go to the <a href='/auth/sharedcookie/callback'>callback</a></p>
  HTML
end

get '/auth/:provider/callback' do
  content_type 'text/plain'
  request.env['omniauth.auth'].info.to_hash.inspect
end
