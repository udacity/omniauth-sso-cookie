require "omniauth-sso-cookie/version"
require "omniauth"

module OmniAuth
  module Strategies
    autoload :SsoCookie,  'omniauth/strategies/sso-cookie'
  end
end

OmniAuth.config.add_camelization 'ssocookie', 'SsoCookie'
