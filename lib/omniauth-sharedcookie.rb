require "omniauth-sharedcookie/version"
require "omniauth"

module OmniAuth
  module Strategies
    autoload :SharedCookie,  'omniauth/strategies/sharedcookie'
  end
end

OmniAuth.config.add_camelization 'sharedcookie', 'SharedCookie'
